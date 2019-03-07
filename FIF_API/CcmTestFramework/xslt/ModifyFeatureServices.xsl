<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an Add Feature Service FIF request

  @author goethalo
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="additionalInfoMatches">
  	<xsl:param name="theOne"/>
  	<xsl:param name="theOther"/>

	<xsl:choose>
		<!-- compare number of elements -->
		<xsl:when test="count($theOne/request-param-list-item) != count($theOther/request-param-list-item) ">false-wrongnumber</xsl:when>

		<!-- compare element by element, if the number of elements is the same -->
		<xsl:otherwise>
			<xsl:variable name="mismatchFound">
				<xsl:for-each select="$theOne/request-param-list-item">
					<xsl:variable name="serviceCharCode" select="request-param[@name='serviceCharCode']"/>
					<xsl:variable name="value" select="request-param[@name='value']"/>
					<xsl:if test="count($theOther/request-param-list-item[
							request-param[@name='serviceCharCode'] = $serviceCharCode and
							request-param[@name='value'] = $value]) = 0">
						<xsl:value-of select="concat($serviceCharCode, ';', $value, ';')"/>										
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>			
			<xsl:choose>
				<xsl:when test="$mismatchFound != ''">false-mismatch</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>																			
	</xsl:choose>
  </xsl:template>

  <xsl:template name="serviceExistsInList">
  	<xsl:param name="service"/>
  	<xsl:param name="list"/>
  	
  	<xsl:choose>
  		<!-- simple service, just compare serviceCode -->
		<xsl:when test="$service/request-param[@name='conditionId'] = ''
						and $service/request-param[@name='conditionName'] = ''
						and $service/request-param[@name='articleNumber'] = ''
						and $service/request-param[@name='targetPhoneNumber'] = ''
						and count($service/request-param-list[@name='additionalInfo']/request-param-list-item) = 0
						and count($list/request-param-list-item/request-param-list[@name='additionalInfo']/request-param-list-item) = 0">
			<xsl:value-of select="count($list/request-param-list-item[
						request-param[@name='serviceCode'] = $service/request-param[@name='serviceCode']]) > 0"/>
		</xsl:when>
  		<!-- conditionService, compare serviceCode, conditionId and conditionName -->
		<xsl:when test="$service/request-param[@name='conditionId'] != ''
						or $service/request-param[@name='conditionName'] != ''
						or $service/request-param[@name='articleNumber'] != ''
						or $service/request-param[@name='targetPhoneNumber'] != ''">
			<xsl:value-of select="count($list/request-param-list-item[
						request-param[@name='serviceCode'] = $service/request-param[@name='serviceCode'] and 
						request-param[@name='conditionId'] = $service/request-param[@name='conditionId'] and 
						request-param[@name='conditionName'] = $service/request-param[@name='conditionName'] and 
						request-param[@name='articleNumber'] = $service/request-param[@name='articleNumber'] and 
						request-param[@name='targetPhoneNumber'] = $service/request-param[@name='targetPhoneNumber']]) > 0"/>
		</xsl:when>
  		<!-- service with additionalInfo, compare serviceCode and additionalInfo -->
		<xsl:when test="count($service/request-param-list[@name='additionalInfo']/request-param-list-item) > 0
						or count($list/request-param-list-item/request-param-list[@name='additionalInfo']/request-param-list-item) > 0">
			<xsl:choose>
				<!-- check, if there is a service with the same serviceCode -->
				<xsl:when test="count($list/request-param-list-item[
						request-param[@name='serviceCode'] = $service/request-param[@name='serviceCode']]) = 0">
					<xsl:text>false</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="serviceCode" select="$service/request-param[@name='serviceCode']"/>
					<xsl:variable name="matchFound">
						<xsl:for-each select="$list/request-param-list-item[request-param[@name='serviceCode'] = $serviceCode]">
							<xsl:variable name="additionalInfoMatches">												
								<xsl:call-template name="additionalInfoMatches">
									<xsl:with-param name="theOne" select="request-param-list[@name='additionalInfo']"/>
									<xsl:with-param name="theOther" select="$service/request-param-list[@name='additionalInfo']"/>									
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="$additionalInfoMatches = 'true'">true</xsl:if>							
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$matchFound != ''">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose> 
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:when>
  	</xsl:choose>
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
      <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>

      <xsl:variable name="desiredDate">
        <xsl:choose>
          <xsl:when test ="request-param[@name='desiredDate'] = '' or
            request-param[@name='desiredDate'] = 'today' or
            request-param[@name='processingStatus'] = 'completedOPM'">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:when test ="dateutils:compareString(request-param[@name='desiredDate'], $tomorrow) = '-1'">
            <xsl:value-of select="$tomorrow"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="terminationDate" >
        <xsl:choose>          
          <xsl:when test="request-param[@name='synchronizeTermination'] = 'Y'">
            <xsl:value-of select="$desiredDate"/>
          </xsl:when>          
          <xsl:when test="request-param[@name='processingStatus'] = ''">
            <xsl:value-of select="dateutils:createFIFDateOffset($desiredDate, 'DATE', '-1')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$today"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="isMovedService">
        <xsl:value-of select="request-param[@name='isMovedService']"/>
      </xsl:variable>

      <xsl:variable name="contributingItemDate" >
        <xsl:choose>
          <xsl:when test="request-param[@name='processingStatus'] != '' and $isMovedService != 'Y'">
            <xsl:value-of select="dateutils:createFIFDateOffset($desiredDate, 'DATE', '1')"/>
          </xsl:when>
          <xsl:when test="$desiredDate = $today and $isMovedService != 'Y'">
            <xsl:value-of select="dateutils:createFIFDateOffset($desiredDate, 'DATE', '1')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$desiredDate"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="contributingItemStopDate" >
        <xsl:value-of select="$contributingItemDate"/>
      </xsl:variable>

      <xsl:variable name="ignoreDuplicates" >
        <xsl:value-of select="request-param[@name='ignoreDuplicates']"/>
      </xsl:variable>
      
      <xsl:variable name="skipCheckForOpenTermination" >
        <xsl:value-of select="request-param[@name='skipCheckForOpenTermination']"/>
      </xsl:variable>
      
      <xsl:variable name="ignoreTerminationError" >
        <xsl:value-of select="request-param[@name='ignoreTerminationError']"/>
      </xsl:variable>
      
      <xsl:variable name="serviceSubscriptionId">
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable>
      
      <xsl:variable name="functionID">
        <xsl:value-of select="request-param[@name='functionID']"/>
      </xsl:variable>
      
      <xsl:variable name="requestListId">
      	<xsl:value-of select="request-param[@name='requestListId']"/>
      </xsl:variable>
      
      <xsl:variable name="reason">
        <xsl:value-of select="request-param[@name='reason']"/>
      </xsl:variable>

      <xsl:variable name="ignoreWrongServiceCode">
        <xsl:value-of select="request-param[@name='ignoreWrongServiceCode']"/>
      </xsl:variable>

      <xsl:variable name="action">
        <xsl:value-of select="request-param[@name='action']"/>
      </xsl:variable>

      <xsl:variable name="salesOrganisationNumber">
        <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
      </xsl:variable>

      <xsl:variable name="salesOrganisationNumberVF">
        <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
      </xsl:variable>

      <xsl:variable name="subOrderId">
        <xsl:value-of select="request-param[@name='subOrderId']"/>
      </xsl:variable>
      
      <xsl:variable name="providerTrackingNumber">
        <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
      </xsl:variable>
      
      <xsl:variable name="parentServiceCode">
        <xsl:value-of select="request-param[@name='parentServiceCode']"/>
      </xsl:variable>      
      
      <xsl:variable name="termExistingBWServices" >
        <xsl:value-of select="request-param[@name='termExistingBWServices']"/>
      </xsl:variable>
      
      <xsl:variable name="orderDate">
         <xsl:if test="request-param[@name='reason'] = 'RELOCATION'
                        or request-param[@name='reason'] = 'PRODUCT_CHANGE'
                        or request-param[@name='reason'] = 'PRODCHANGE_BAS'
                        or request-param[@name='reason'] = 'PRODCHANGE_PREM'">
            <xsl:value-of select="request-param[@name='somDate']"/>
         </xsl:if>
      </xsl:variable>					

      <xsl:variable name="OMTSOrderID" >
        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
      </xsl:variable>
      
      <xsl:variable name="handleAsynchronousTermination" >
        <xsl:value-of select="request-param[@name='handleAsynchronousTermination']"/>
      </xsl:variable>

      <xsl:element name="CcmFifReadExternalNotificationCmd">
        <xsl:element name="command_id">read_customer_order</xsl:element>
        <xsl:element name="CcmFifReadExternalNotificationInCont">
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="parameter_name">
            <xsl:value-of select="$functionID"/>
            <xsl:if test="request-param[@name='workflowType'] = 'COM-OPM-FIF'
              and request-param[@name='processingStatus'] = ''">
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

      <xsl:if test="$serviceSubscriptionId = ''">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_service_subscription</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:value-of select="$functionID"/>
              <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_main_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="$serviceSubscriptionId != ''">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="$serviceSubscriptionId"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="$serviceSubscriptionId = ''">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_service_subscription</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">read_service_subscription</xsl:element>
              <xsl:element name="field_name">value_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>


       
      <xsl:if test="$parentServiceCode != ''">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_parent_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">
              <xsl:value-of select="$parentServiceCode"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
  
      <!-- termination part START -->
      <xsl:choose>
        <!-- termination for clones services do nothing, handled by terminateFunction -->
        <xsl:when test="$isMovedService = 'Y'"/>

          <!-- termination for not cloned and only BW services if action remove or configuredServiceList exists-->
          <xsl:when test="$isMovedService = 'N' 
              and $termExistingBWServices = 'Y' 
              and (count(request-param-list[@name='configuredServiceList']/request-param-list-item) != '0'
              or request-param[@name='action'] = 'remove')">
          <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
              <xsl:variable name="serviceCode">
                  <xsl:value-of select="request-param[@name='serviceCode']"/>
              </xsl:variable>
              <!-- terminate if action remove or not exists in configuredServiceList -->
              <xsl:if test="request-param[@name='action'] = 'remove'
                  or count(../../request-param-list[@name='configuredServiceList']/request-param-list-item[
                  request-param[@name='serviceCode'] = $serviceCode]) = '0'">              
                  
                  <!-- look for open STP for the respective service in state ASSIGNED or UNASSIGNED -->
                  <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                      <xsl:element name="command_id">
                          <xsl:text>find_open_stp_</xsl:text>
                          <xsl:value-of select="position()"/>
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
                                      <xsl:value-of select="$serviceCode"/>
                                  </xsl:element>
                                  <xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>                                            
                              </xsl:element>
                              <xsl:element name="CcmFifFindStpParameterCont">
                                  <xsl:element name="service_code">
                                      <xsl:value-of select="$serviceCode"/>
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
                                  <xsl:value-of select="position()"/>
                              </xsl:element>
                              <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
                          </xsl:element>
                          <xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
                          <xsl:element name="process_ind_ref">
                              <xsl:element name="command_id">
                                  <xsl:text>find_open_stp_</xsl:text>
                                  <xsl:value-of select="position()"/>
                              </xsl:element>
                              <xsl:element name="field_name">stp_found</xsl:element>          	
                          </xsl:element>
                          <xsl:element name="required_process_ind">Y</xsl:element>            
                      </xsl:element>
                  </xsl:element>              
                  
                  <xsl:if test="$skipCheckForOpenTermination != 'Y'">
                      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                          <xsl:element name="command_id">
                              <xsl:text>find_terminate_stp_</xsl:text>
                              <xsl:value-of select="position()"/>
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
                                          <xsl:value-of select="$serviceCode"/>
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
                                  <xsl:value-of select="$serviceCode"/>
                                  <xsl:text>. Bitte vor erneuter Verarbeitung stornieren.</xsl:text>
                              </xsl:element>
                              <xsl:element name="process_ind_ref">
                                  <xsl:element name="command_id">
                                      <xsl:text>find_terminate_stp_</xsl:text>
                                      <xsl:value-of select="position()"/>
                                  </xsl:element>
                                  <xsl:element name="field_name">stp_found</xsl:element>
                              </xsl:element>
                              <xsl:element name="required_process_ind">Y</xsl:element>                  
                          </xsl:element>
                      </xsl:element>                                      
                  </xsl:if>
                  
                  <!-- Terminate existing Bandwidth/Upstream Bandwidth services -->
                  <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
                      <xsl:element name="command_id">
                          <xsl:text>term_feature_</xsl:text>
                          <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
                          <xsl:element name="service_subscription_ref">
                              <xsl:element name="command_id">
                                  <xsl:choose>
                                      <xsl:when test="$parentServiceCode != ''">find_parent_service</xsl:when>
                                      <xsl:otherwise>find_main_service</xsl:otherwise>
                                  </xsl:choose>
                              </xsl:element>
                              <xsl:element name="field_name">service_subscription_id</xsl:element>
                          </xsl:element>
                          <xsl:element name="no_child_error_ind">N</xsl:element>
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
                          <xsl:element name="service_code_list">
                            <xsl:choose>
                              <xsl:when test="$parentServiceCode != ''">
                                <!-- Upstream Bandwidth services -->
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0196</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0197</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0198</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0199</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V019F</xsl:element>
                                </xsl:element>
                              </xsl:when>
                              <xsl:otherwise>
                                <!-- Bandwidth services -->
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0115</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0116</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0117</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0118</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0133</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0174</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0175</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0176</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0177</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0178</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0179</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V0180</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018A</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018B</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018C</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018D</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018G</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018H</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018N</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V017E</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018J</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V017J</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018O</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V017K</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018P</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V017L</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018Q</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V017M</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">V018R</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">I1217</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">I1218</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">I1220</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">I1221</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">I1224</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG001</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG002</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG003</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG004</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG005</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG006</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG007</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG008</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                  <xsl:element name="service_code">IG009</xsl:element>
                                </xsl:element>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:element>
                      </xsl:element>
                  </xsl:element>
              </xsl:if>
          </xsl:for-each>
        </xsl:when>  
          <!-- termination for not cloned no BW services if configuredServiceList exists-->
          <xsl:when test="$isMovedService = 'N'
              and $termExistingBWServices != 'Y' 
              and count(request-param-list[@name='configuredServiceList']/request-param-list-item) != '0'">
            
          <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
            <xsl:variable name="existingInConfigured">
	            <xsl:call-template name="serviceExistsInList">
	            	<xsl:with-param name="service" select="."/>
	            	<xsl:with-param name="list" select="../../request-param-list[@name='configuredServiceList']"/>            	
	            </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="serviceCode">
              <xsl:value-of select="request-param[@name='serviceCode']"/>
            </xsl:variable>
            <xsl:variable name="conditionId">
              <xsl:value-of select="request-param[@name='conditionId']"/>
            </xsl:variable>
            <xsl:variable name="conditionName">
              <xsl:value-of select="request-param[@name='conditionName']"/>
            </xsl:variable>        
            
            <!-- terminate if not not exists in configuredServiceList -->
            <xsl:if test="$existingInConfigured = 'false'">              

				<!-- find the service, which is supposed to be terminated -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">
						<xsl:text>find_service_to_terminate_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_service_subs_id">
							<xsl:value-of select="$serviceSubscriptionId"/>
						</xsl:element>
						<xsl:element name="no_stp_error">
							<xsl:choose>
								<xsl:when test="$ignoreTerminationError = 'Y'">N</xsl:when>
								<xsl:otherwise>Y</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="find_stp_parameters">
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">
									<xsl:value-of select="$serviceCode"/>
								</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="customer_order_state">FINAL</xsl:element>
								<xsl:choose>
									<!-- use conditionId in search for STP -->
									<xsl:when test="(request-param[@name='conditionName'] != '' or 
										request-param[@name='conditionId'] != '') 
										and (
										$serviceCode = 'V0303' or 
										$serviceCode = 'V0045' or
										$serviceCode = 'V0046' or
										$serviceCode = 'V004A' or
										$serviceCode = 'V0317' or
										$serviceCode = 'V0318')">                            
										<xsl:element name="service_char_code">
										  	<xsl:choose>
												<xsl:when test="$serviceCode = 'V0303'">V0212</xsl:when>
												<xsl:when test="$serviceCode = 'V0045'">V0095</xsl:when>
												<xsl:when test="$serviceCode = 'V0046'">V0096</xsl:when>
												<xsl:when test="$serviceCode = 'V004A'">V0113</xsl:when>
												<xsl:when test="$serviceCode = 'V0317'">V0192</xsl:when>
												<xsl:when test="$serviceCode = 'V0318'">V0193</xsl:when>
											</xsl:choose>
										</xsl:element>
										<xsl:element name="configured_value_string">
											<xsl:value-of select="request-param[@name='conditionName']"/>
									    </xsl:element>  
									</xsl:when>
									<!-- if the service contains additional info, look for the first one -->
									<xsl:when test="count(request-param-list[@name='additionalInfo']/request-param-list-item) > 0">
										<xsl:for-each select="request-param-list[@name='additionalInfo']/request-param-list-item">
											<xsl:if test="position() = 1">											
												<xsl:element name="service_char_code">
													<xsl:value-of select="request-param[@name='serviceCharCode']"/>
												</xsl:element>
												<xsl:element name="configured_value_string">
                                                  <xsl:choose>
		                  							<xsl:when test="request-param[@name='serviceCharCode'] = 'V0946' or request-param[@name='serviceCharCode'] = 'V0947'">
			                							<xsl:value-of select="dateutils:SOM2OPMDate(request-param[@name='value'])"/>
		                  							</xsl:when>
		                  							<xsl:otherwise>
														<xsl:value-of select="request-param[@name='value']"/>
		                  							</xsl:otherwise>
                                                  </xsl:choose>
											    </xsl:element>  				
										    </xsl:if>							
									    </xsl:for-each>
									</xsl:when>
								</xsl:choose>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>

              <!-- look for open STP for the respective service in state ASSIGNED or UNASSIGNED -->
              <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                <xsl:element name="command_id">
                  <xsl:text>find_open_stp_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                  <xsl:element name="service_subscription_id_ref">
	                <xsl:element name="command_id">
	                  <xsl:text>find_service_to_terminate_</xsl:text>
	                  <xsl:value-of select="position()"/>
	                </xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="no_stp_error">N</xsl:element>
                  <xsl:element name="find_stp_parameters">
                    <xsl:element name="CcmFifFindStpParameterCont">
                      <xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>                                            
                    </xsl:element>
                    <xsl:element name="CcmFifFindStpParameterCont">
                      <xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>                                            
                    </xsl:element>
                  </xsl:element>
                  <xsl:if test="$ignoreTerminationError = 'Y'">
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">
                        <xsl:text>find_service_to_terminate_</xsl:text>
                        <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="field_name">stp_found</xsl:element>          	
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:if>            
                </xsl:element>
              </xsl:element>
              
              <!-- cancel the ASSIGNED or UNASSIGNED STP -->
              <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
                <xsl:element name="command_id">cancel_open_stp</xsl:element>
                <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
                  <xsl:element name="service_ticket_position_id_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_open_stp_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
                  </xsl:element>
                  <xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_open_stp_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">stp_found</xsl:element>          	
                  </xsl:element>
                  <xsl:element name="required_process_ind">Y</xsl:element>            
                </xsl:element>
              </xsl:element>              
                            
              <xsl:if test="$skipCheckForOpenTermination != 'Y'">
                <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                  <xsl:element name="command_id">
                    <xsl:text>find_terminate_stp_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="CcmFifFindServiceTicketPositionInCont">
	                  <xsl:element name="service_subscription_id_ref">
		                <xsl:element name="command_id">
		                  <xsl:text>find_service_to_terminate_</xsl:text>
		                  <xsl:value-of select="position()"/>
		                </xsl:element>
	                    <xsl:element name="field_name">service_subscription_id</xsl:element>
	                  </xsl:element>
                    <xsl:element name="no_stp_error">N</xsl:element>
                    <xsl:element name="find_stp_parameters">
                      <xsl:element name="CcmFifFindStpParameterCont">
                        <xsl:element name="usage_mode_value_rd">4</xsl:element>
                        <xsl:element name="customer_order_state">RELEASED</xsl:element>
                      </xsl:element>
                    </xsl:element>
                    <xsl:if test="$ignoreTerminationError = 'Y'">
                      <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">
                          <xsl:text>find_service_to_terminate_</xsl:text>
                          <xsl:value-of select="position()"/>
                        </xsl:element>
                        <xsl:element name="field_name">stp_found</xsl:element>          	
                      </xsl:element>
                      <xsl:element name="required_process_ind">Y</xsl:element>
                    </xsl:if>            
                  </xsl:element>
                </xsl:element>
                
                <xsl:element name="CcmFifRaiseErrorCmd">
                  <xsl:element name="command_id">termination_stp_exists</xsl:element>
                  <xsl:element name="CcmFifRaiseErrorInCont">
                    <xsl:element name="error_text">
                      <xsl:text>Offene Kuendigung besteht bereits für Dienst </xsl:text>
                      <xsl:value-of select="$serviceCode"/>
                      <xsl:text>. Bitte vor erneuter Verarbeitung stornieren.</xsl:text>
                    </xsl:element>
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">
                        <xsl:text>find_terminate_stp_</xsl:text>
                        <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="field_name">stp_found</xsl:element>
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>                  
                  </xsl:element>
                </xsl:element>                                      
              </xsl:if>
              
              <!-- Terminate serviceSubscription -->
              <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
                <xsl:element name="command_id">
                  <xsl:text>term_feature_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_service_to_terminate_</xsl:text>
                      <xsl:value-of select="position()"/>                  
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
                    <xsl:value-of select="$providerTrackingNumber"/>
                  </xsl:element>
                  <xsl:if test="$ignoreTerminationError = 'Y'">
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">
                        <xsl:text>find_service_to_terminate_</xsl:text>
                        <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="field_name">stp_found</xsl:element>          	
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:if>            
                </xsl:element>
              </xsl:element>                        
              
	          <xsl:if test="request-param[@name='handleSelectedDestination'] = 'Y' and request-param[@name='targetPhoneNumber'] != ''">
	            <!-- Find Price Plan with selected destination -->      
	            <xsl:element name="CcmFifFindPricePlanSubsCmd">
	              <xsl:element name="command_id">
	                <xsl:text>find_pps_for_term_</xsl:text>
	                <xsl:value-of select="position()"/>
	              </xsl:element>
	              <xsl:element name="CcmFifFindPricePlanSubsInCont">
	                <xsl:element name="service_subscription_id_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>find_service_to_terminate_</xsl:text>
                        <xsl:value-of select="position()"/>                  
	                  </xsl:element>
	                  <xsl:element name="field_name">service_subscription_id</xsl:element>
	                </xsl:element>
	                <xsl:element name="effective_date">
	                  <xsl:value-of select="$terminationDate"/>
	                </xsl:element>                  
	                <xsl:element name="selected_destination_ind">Y</xsl:element>
	                <xsl:element name="process_ind_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>term_feature_</xsl:text>
                        <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">stp_created</xsl:element>	                  
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>
	              </xsl:element>
	            </xsl:element>
	
	            <!-- add selected destination -->
	            <xsl:element name="CcmFifConfigurePPSCmd">
	              <xsl:element name="command_id">
	                <xsl:text>config_pps_for_term_</xsl:text>
	                <xsl:value-of select="position()"/>              
	              </xsl:element>
	              <xsl:element name="CcmFifConfigurePPSInCont">
	                <xsl:element name="price_plan_subs_list_ref">
	                  <xsl:element name="command_id">
	                    <xsl:text>find_pps_for_term_</xsl:text>
	                    <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">price_plan_subs_list</xsl:element>
	                </xsl:element>
	                <xsl:element name="effective_date">
	                  <xsl:value-of select="$terminationDate"/>
	                </xsl:element>                  
	                <xsl:element name="selected_destinations_list">
	                  <xsl:element name="CcmFifSelectedDestCont">
	                    <xsl:element name="begin_number">
	                      <xsl:value-of select="request-param[@name='targetPhoneNumber']"/>
	                    </xsl:element>
	                    <xsl:element name="stop_date">
	                      <xsl:value-of select="$terminationDate"/>
	                    </xsl:element>
	                  </xsl:element>
	                </xsl:element>
	                <xsl:element name="process_ind_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>term_feature_</xsl:text>
                        <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">stp_created</xsl:element>
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>
	              </xsl:element>
	            </xsl:element>
	          </xsl:if>
              
              <!-- stop contributing item, if this was a tariff option or desired country -->
              <xsl:if test="request-param[@name='handleContributingItem'] = 'Y'">
                <xsl:element name="CcmFifAddModifyContributingItemCmd">
                  <xsl:element name="command_id">
                    <xsl:text>stop_contributing_item_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="CcmFifAddModifyContributingItemInCont">
                    <xsl:element name="product_subscription_ref">
                      <xsl:element name="command_id">find_main_service</xsl:element>
                      <xsl:element name="field_name">product_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="service_code">
                      <xsl:value-of select="$serviceCode"/>
                    </xsl:element>
                    <xsl:element name="contributing_item_list">
                      <xsl:element name="CcmFifContributingItem">
                        <xsl:element name="supported_object_type_rd">
                          <xsl:choose>
                            <xsl:when test="request-param[@name='contributingItemType'] != ''">
                              <xsl:value-of select="request-param[@name='contributingItemType']"/>
                            </xsl:when>
                            <xsl:otherwise>SERVICE_SUBSC</xsl:otherwise>
                          </xsl:choose>
                        </xsl:element>
                        <xsl:element name="stop_date">
                          <xsl:value-of select="$contributingItemStopDate"/>
                        </xsl:element>
                        <xsl:choose>
                          <xsl:when test="request-param[@name='contributingItemType'] = 'PRODUCT_SUBSC'">
                            <xsl:element name="product_subscription_ref">
                              <xsl:element name="command_id">find_main_service</xsl:element>
                              <xsl:element name="field_name">product_subscription_id</xsl:element>
                            </xsl:element>                          
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:element name="service_subscription_ref">
                              <xsl:element name="command_id">find_main_service</xsl:element>
                              <xsl:element name="field_name">service_subscription_id</xsl:element>
                            </xsl:element>                          
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:element>
                    </xsl:element>
	                <xsl:element name="process_ind_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>term_feature_</xsl:text>
                        <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">stp_created</xsl:element>
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- terminate if action remove -->
          <xsl:if test="request-param[@name='action'] = 'remove'">
            <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
              <xsl:variable name="serviceCode">
                <xsl:value-of select="request-param[@name='serviceCode']"/>
              </xsl:variable>
              
				<!-- find the service, which is supposed to be terminated -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">
						<xsl:text>find_service_to_terminate_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_service_subs_id">
							<xsl:value-of select="$serviceSubscriptionId"/>
						</xsl:element>
						<xsl:element name="no_stp_error">
							<xsl:choose>
								<xsl:when test="$ignoreTerminationError = 'Y'">N</xsl:when>
								<xsl:otherwise>Y</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="find_stp_parameters">
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">
									<xsl:value-of select="$serviceCode"/>
								</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="customer_order_state">FINAL</xsl:element>
								<xsl:choose>
									<!-- use conditionId in search for STP -->
									<xsl:when test="(request-param[@name='conditionName'] != '' or 
										request-param[@name='conditionId'] != '') 
										and (
										$serviceCode = 'V0303' or 
										$serviceCode = 'V0045' or
										$serviceCode = 'V0046' or
										$serviceCode = 'V004A' or
										$serviceCode = 'V0317' or
										$serviceCode = 'V0318')">                            
										<xsl:element name="service_char_code">
										  	<xsl:choose>
												<xsl:when test="$serviceCode = 'V0303'">V0212</xsl:when>
												<xsl:when test="$serviceCode = 'V0045'">V0095</xsl:when>
												<xsl:when test="$serviceCode = 'V0046'">V0096</xsl:when>
												<xsl:when test="$serviceCode = 'V004A'">V0113</xsl:when>
												<xsl:when test="$serviceCode = 'V0317'">V0192</xsl:when>
												<xsl:when test="$serviceCode = 'V0318'">V0193</xsl:when>
											</xsl:choose>
										</xsl:element>
										<xsl:element name="configured_value_string">
											<xsl:value-of select="request-param[@name='conditionName']"/>
									    </xsl:element>  
									</xsl:when>
									<!-- if the service contains additional info, look for the first one -->
									<xsl:when test="count(request-param-list[@name='additionalInfo']/request-param-list-item) > 0">
										<xsl:for-each select="request-param-list[@name='additionalInfo']/request-param-list-item">
											<xsl:if test="position() = 1">											
												<xsl:element name="service_char_code">
													<xsl:value-of select="request-param[@name='serviceCharCode']"/>
												</xsl:element>
												<xsl:element name="configured_value_string">
                                                  <xsl:choose>
		                  							<xsl:when test="request-param[@name='serviceCharCode'] = 'V0946' or request-param[@name='serviceCharCode'] = 'V0947'">
			                							<xsl:value-of select="dateutils:SOM2OPMDate(request-param[@name='value'])"/>
		                  							</xsl:when>
		                  							<xsl:otherwise>
														<xsl:value-of select="request-param[@name='value']"/>
		                  							</xsl:otherwise>
                                                  </xsl:choose>
											    </xsl:element>  				
										    </xsl:if>							
									    </xsl:for-each>
									</xsl:when>
								</xsl:choose>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>

              <!-- look for open STP for the respective service in state ASSIGNED or UNASSIGNED -->
              <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                <xsl:element name="command_id">
                  <xsl:text>find_open_stp_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                  <xsl:element name="service_subscription_id_ref">
	                <xsl:element name="command_id">
	                  <xsl:text>find_service_to_terminate_</xsl:text>
	                  <xsl:value-of select="position()"/>
	                </xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="no_stp_error">N</xsl:element>
                  <xsl:element name="find_stp_parameters">
                    <xsl:element name="CcmFifFindStpParameterCont">
                      <xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>                                            
                    </xsl:element>
                    <xsl:element name="CcmFifFindStpParameterCont">
                      <xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>                                            
                    </xsl:element>
                  </xsl:element>
                  <xsl:if test="$ignoreTerminationError = 'Y'">
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">
                        <xsl:text>find_service_to_terminate_</xsl:text>
                        <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="field_name">stp_found</xsl:element>          	
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:if>            
                </xsl:element>
              </xsl:element>
              
              <!-- cancel the ASSIGNED or UNASSIGNED STP -->
              <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
                <xsl:element name="command_id">cancel_open_stp</xsl:element>
                <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
                  <xsl:element name="service_ticket_position_id_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_open_stp_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
                  </xsl:element>
                  <xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_open_stp_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">stp_found</xsl:element>          	
                  </xsl:element>
                  <xsl:element name="required_process_ind">Y</xsl:element>            
                </xsl:element>
              </xsl:element>              
              
              <xsl:if test="$skipCheckForOpenTermination != 'Y'">
                <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                  <xsl:element name="command_id">
                    <xsl:text>find_terminate_stp_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="CcmFifFindServiceTicketPositionInCont">
	                  <xsl:element name="service_subscription_id_ref">
		                <xsl:element name="command_id">
		                  <xsl:text>find_service_to_terminate_</xsl:text>
		                  <xsl:value-of select="position()"/>
		                </xsl:element>
	                    <xsl:element name="field_name">service_subscription_id</xsl:element>
	                  </xsl:element>
                    <xsl:element name="no_stp_error">N</xsl:element>
                    <xsl:element name="find_stp_parameters">
                      <xsl:element name="CcmFifFindStpParameterCont">
                        <xsl:element name="usage_mode_value_rd">4</xsl:element>
                        <xsl:element name="customer_order_state">RELEASED</xsl:element>
                      </xsl:element>
                    </xsl:element>
                    <xsl:if test="$ignoreTerminationError = 'Y'">
                      <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">
                          <xsl:text>find_service_to_terminate_</xsl:text>
                          <xsl:value-of select="position()"/>
                        </xsl:element>
                        <xsl:element name="field_name">stp_found</xsl:element>          	
                      </xsl:element>
                      <xsl:element name="required_process_ind">Y</xsl:element>
                    </xsl:if>            
                  </xsl:element>
                </xsl:element>
                
                <xsl:element name="CcmFifRaiseErrorCmd">
                  <xsl:element name="command_id">termination_stp_exists</xsl:element>
                  <xsl:element name="CcmFifRaiseErrorInCont">
                    <xsl:element name="error_text">
                      <xsl:text>Offene Kuendigung besteht bereits für Dienst </xsl:text>
                      <xsl:value-of select="$serviceCode"/>
                      <xsl:text>. Bitte vor erneuter Verarbeitung stornieren.</xsl:text>
                    </xsl:element>
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">
                        <xsl:text>find_terminate_stp_</xsl:text>
                        <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="field_name">stp_found</xsl:element>
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>                  
                  </xsl:element>
                </xsl:element>                                      
              </xsl:if>
              
              <!-- Terminate serviceSubscription -->
              <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
                <xsl:element name="command_id">
                  <xsl:text>term_feature_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_service_to_terminate_</xsl:text>
                      <xsl:value-of select="position()"/>                  
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
                    <xsl:value-of select="$providerTrackingNumber"/>
                  </xsl:element>
                  <xsl:if test="$ignoreTerminationError = 'Y'">
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">
                        <xsl:text>find_service_to_terminate_</xsl:text>
                        <xsl:value-of select="position()"/>
                      </xsl:element>
                      <xsl:element name="field_name">stp_found</xsl:element>          	
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:if>            
                </xsl:element>
              </xsl:element>                        
              
	          <xsl:if test="request-param[@name='handleSelectedDestination'] = 'Y' and request-param[@name='targetPhoneNumber'] != ''">
	            <!-- Find Price Plan with selected destination -->      
	            <xsl:element name="CcmFifFindPricePlanSubsCmd">
	              <xsl:element name="command_id">
	                <xsl:text>find_pps_for_term_</xsl:text>
	                <xsl:value-of select="position()"/>
	              </xsl:element>
	              <xsl:element name="CcmFifFindPricePlanSubsInCont">
	                <xsl:element name="service_subscription_id_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>find_service_to_terminate_</xsl:text>
                        <xsl:value-of select="position()"/>                  
	                  </xsl:element>
	                  <xsl:element name="field_name">service_subscription_id</xsl:element>
	                </xsl:element>
	                <xsl:element name="effective_date">
	                  <xsl:value-of select="$terminationDate"/>
	                </xsl:element>                  
	                <xsl:element name="selected_destination_ind">Y</xsl:element>
	                <xsl:element name="process_ind_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>term_feature_</xsl:text>
                        <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">stp_created</xsl:element>	                  
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>
	              </xsl:element>
	            </xsl:element>
	
	            <!-- add selected destination -->
	            <xsl:element name="CcmFifConfigurePPSCmd">
	              <xsl:element name="command_id">
	                <xsl:text>config_pps_for_term_</xsl:text>
	                <xsl:value-of select="position()"/>              
	              </xsl:element>
	              <xsl:element name="CcmFifConfigurePPSInCont">
	                <xsl:element name="price_plan_subs_list_ref">
	                  <xsl:element name="command_id">
	                    <xsl:text>find_pps_for_term_</xsl:text>
	                    <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">price_plan_subs_list</xsl:element>
	                </xsl:element>
	                <xsl:element name="effective_date">
	                  <xsl:value-of select="$terminationDate"/>
	                </xsl:element>                  
	                <xsl:element name="selected_destinations_list">
	                  <xsl:element name="CcmFifSelectedDestCont">
	                    <xsl:element name="begin_number">
	                      <xsl:value-of select="request-param[@name='targetPhoneNumber']"/>
	                    </xsl:element>
	                    <xsl:element name="stop_date">
	                      <xsl:value-of select="$terminationDate"/>
	                    </xsl:element>
	                  </xsl:element>
	                </xsl:element>
	                <xsl:element name="process_ind_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>term_feature_</xsl:text>
                        <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">stp_created</xsl:element>
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>
	              </xsl:element>
	            </xsl:element>
	          </xsl:if>
                            
              <!-- stop contributing item, if this was a tariff option or desired country -->
              <xsl:if test="request-param[@name='handleContributingItem'] = 'Y'">
                <xsl:element name="CcmFifAddModifyContributingItemCmd">
                  <xsl:element name="command_id">
                    <xsl:text>stop_contributing_item_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="CcmFifAddModifyContributingItemInCont">
                    <xsl:element name="product_subscription_ref">
                      <xsl:element name="command_id">find_main_service</xsl:element>
                      <xsl:element name="field_name">product_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="service_code">
                      <xsl:value-of select="$serviceCode"/>
                    </xsl:element>
                    <xsl:element name="contributing_item_list">
                      <xsl:element name="CcmFifContributingItem">                      
                        <xsl:element name="supported_object_type_rd">
                          <xsl:choose>
                            <xsl:when test="request-param[@name='contributingItemType'] != ''">
                              <xsl:value-of select="request-param[@name='contributingItemType']"/>
                            </xsl:when>
                            <xsl:otherwise>SERVICE_SUBSC</xsl:otherwise>
                          </xsl:choose>
                        </xsl:element>
                        <xsl:element name="stop_date">
                          <xsl:value-of select="$contributingItemStopDate"/>
                        </xsl:element>
                        <xsl:choose>
                          <xsl:when test="request-param[@name='contributingItemType'] = 'PRODUCT_SUBSC'">
                            <xsl:element name="product_subscription_ref">
                              <xsl:element name="command_id">find_main_service</xsl:element>
                              <xsl:element name="field_name">product_subscription_id</xsl:element>
                            </xsl:element>                          
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:element name="service_subscription_ref">
                              <xsl:element name="command_id">find_main_service</xsl:element>
                              <xsl:element name="field_name">service_subscription_id</xsl:element>
                            </xsl:element>                          
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:element>
                    </xsl:element>
	                <xsl:element name="process_ind_ref">
	                  <xsl:element name="command_id">
                        <xsl:text>term_feature_</xsl:text>
                        <xsl:value-of select="position()"/>
	                  </xsl:element>
	                  <xsl:element name="field_name">stp_created</xsl:element>
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              
            </xsl:for-each>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <!-- termination part END -->

      <!-- subscription part START -->
      <!-- subscribe if cloned service and no configuredServiceList -->
      <xsl:if test="$isMovedService = 'Y' and $action != 'remove' and
        count(request-param-list[@name='configuredServiceList']/request-param-list-item) = 0">
        <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
          <xsl:variable name="serviceCode">
            <xsl:value-of select="request-param[@name='serviceCode']"/>
          </xsl:variable>
  
          <xsl:variable name="terminationDateAsyncGTDesiredDate" >
            <xsl:choose>          
              <xsl:when test="request-param[@name='terminationDate'] = ''">
                <xsl:text>Y</xsl:text>
              </xsl:when>          
              <xsl:when test="request-param[@name='terminationDate'] != ''
                and dateutils:compareString(request-param[@name='terminationDate'], $desiredDate) = '1'">
                <xsl:text>Y</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>N</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:if test="$serviceCode = 'V0850' or $serviceCode = 'V0854' or $serviceCode = 'V0855'">
            <!-- get GCI entry for articleNumber to retrieve the billing name -->
            <xsl:element name="CcmFifValidateGeneralCodeItemCmd">
              <xsl:element name="command_id">find_article_name</xsl:element>
              <xsl:element name="CcmFifValidateGeneralCodeItemInCont">
                <xsl:element name="group_code">HW_ART_DES</xsl:element>
                <xsl:element name="value">
                  <xsl:value-of select="request-param[@name='articleNumber']"/>
                </xsl:element>
                <xsl:element name="raise_error_if_invalid">Y</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>

          <!-- Add Feature Service -->
          <xsl:if test="$handleAsynchronousTermination != 'Y' or
                        $handleAsynchronousTermination = 'Y' and $terminationDateAsyncGTDesiredDate = 'Y'">
	          <xsl:element name="CcmFifAddServiceSubsCmd">
	            <xsl:element name="command_id">
	              <xsl:text>add_service_</xsl:text>
	              <xsl:value-of select="position()"/>
	            </xsl:element>
	            <xsl:element name="CcmFifAddServiceSubsInCont">
	              <xsl:element name="product_subscription_ref">
	                <xsl:element name="command_id">find_main_service</xsl:element>
	                <xsl:element name="field_name">product_subscription_id</xsl:element>
	              </xsl:element>
	              <xsl:element name="service_code">
	                <xsl:value-of select="$serviceCode"/>
	              </xsl:element>
	              <xsl:element name="sales_organisation_number">
	                <xsl:value-of select="$salesOrganisationNumber"/>
	              </xsl:element>
	              <xsl:element name="sales_organisation_number_vf">
	                <xsl:value-of select="$salesOrganisationNumberVF"/>
	              </xsl:element>
	              <xsl:element name="parent_service_subs_ref">
	                <xsl:element name="command_id">
	                  <xsl:choose>
	                    <xsl:when test="$parentServiceCode != ''">find_parent_service</xsl:when>
	                    <xsl:otherwise>find_main_service</xsl:otherwise>
	                  </xsl:choose>
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
	              <xsl:element name="account_number_ref">
	                <xsl:element name="command_id">find_main_service</xsl:element>
	                <xsl:element name="field_name">account_number</xsl:element>
	              </xsl:element>
	              <xsl:element name="order_date">
	                <xsl:value-of select="$orderDate"/>
	              </xsl:element>
	              <xsl:element name="ignore_if_service_exist">
	                <xsl:value-of select="$ignoreDuplicates"/>
	              </xsl:element>              
	              <xsl:element name="use_current_pc_version">Y</xsl:element>
	              <xsl:element name="ignore_wrong_service_code">
	                <xsl:choose>
	                  <xsl:when test="$ignoreWrongServiceCode != ''">
	                    <xsl:value-of select="$ignoreWrongServiceCode"/>
	                  </xsl:when>
	                  <xsl:otherwise>
	                    <xsl:value-of select="$isMovedService"/>
	                  </xsl:otherwise>
	                </xsl:choose>
	              </xsl:element>
	              <xsl:element name="service_characteristic_list">
	                <xsl:choose>
	                  <xsl:when test="$serviceCode = 'V0303'">
	                    <!-- DelightDescription -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0212</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Delightcode -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0211</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- DelightEnddate -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0213</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='endDate']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0045'">
	                    <!-- Kondition einmalig -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0095</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition einmalig ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0160</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0046'">
	                    <!-- Kondition monatlich -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0096</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition monatlich ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0161</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Startdatum -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0200</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='startDate']"/>
	                      </xsl:element>
	                    </xsl:element>                    
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V004A'">
	                    <!-- Sonderprämien -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0113</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Sonderprämie ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0209</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Sonderprämie Gutscheincode -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0210</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='specialBonusCode']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0317'">
	                    <!-- Kondition einmalig -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0192</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition einmalig ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0194</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0318'">
	                    <!-- Kondition monatlich -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0193</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition monatlich ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0195</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Startdatum -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0200</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='startDate']"/>
	                      </xsl:element>
	                    </xsl:element>                    
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0850' or $serviceCode = 'V0854' or $serviceCode = 'V0855'">
	                    <!-- Unterdrückung Einmalpreis -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0882</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:choose>
	                          <xsl:when test="request-param[@name='conditionName'] = 'Monatspreis mit Einmalpreisbefreiung'">Ja</xsl:when>
	                          <xsl:otherwise>Nein</xsl:otherwise>
	                        </xsl:choose>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Startdatum -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0200</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='startDate']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  	<xsl:choose>
		                  <xsl:when test="$serviceCode = 'V0854' or $serviceCode = 'V0855'">
		                    <!--  Hardware Artikelnummer Mietpreis -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V9004</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value">
		                        <xsl:choose>
		                      	  <xsl:when test="request-param[@name='conditionId'] = 'keine Mietgebühr'">
		                      	    <xsl:value-of select="request-param[@name='conditionId']"/>
		                      	  </xsl:when>
		                      	  <xsl:otherwise>
		                      	  	<xsl:value-of select="request-param[@name='articleNumber']"/>
		                      	  </xsl:otherwise>
		                        </xsl:choose>
		                      </xsl:element>
		                    </xsl:element>
		                    <!--  Hardware Bezeichnung Mietpreis -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V9005</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value_ref">
		                        <xsl:element name="command_id">find_article_name</xsl:element>
		                        <xsl:element name="field_name">description</xsl:element>
		                      </xsl:element>
		                    </xsl:element>                    
		                  </xsl:when>
		                  <xsl:when test="$serviceCode = 'V0850'">
		                    <!--  Hardware Artikelnummer -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V0880</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value">
		                        <xsl:value-of select="request-param[@name='articleNumber']"/>
		                      </xsl:element>
		                    </xsl:element>
		                    <!--  Hardware Bezeichnung -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V0881</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value_ref">
		                        <xsl:element name="command_id">find_article_name</xsl:element>
		                        <xsl:element name="field_name">description</xsl:element>
		                      </xsl:element>
		                    </xsl:element>                    
		                    <!-- Anzahl -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">VI115</xsl:element>
		                      <xsl:element name="data_type">INTEGER</xsl:element>
		                      <xsl:element name="configured_value">
		                        <xsl:value-of select="request-param[@name='quantity']"/>
		                      </xsl:element>
		                    </xsl:element>                    
		                  </xsl:when>
		 				</xsl:choose>
	                  </xsl:when>
	                  <xsl:when test="request-param[@name='minPeriodDurationValue'] != ''">
	                    <!-- Vertragslaufzeit IP-Centrex -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">VI073</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Vertragslaufzeit -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">I120A</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:choose>
	                          <xsl:when test="request-param[@name='minPeriodDurationValue'] = '12'">1 Jahr</xsl:when>
	                          <xsl:when test="request-param[@name='minPeriodDurationValue'] = '24'">2 Jahre</xsl:when>
	                          <xsl:when test="request-param[@name='minPeriodDurationValue'] = '36'">3 Jahre</xsl:when>
	                        </xsl:choose>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="request-param[@name='hotSubscriptionIndicator'] != ''">
	                    <!-- TV Addons Hot Subscription -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">I1320</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='hotSubscriptionIndicator']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0304'">
	                    <!-- Zielrufnummer -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0230</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='targetPhoneNumber']"/>
	                      </xsl:element>
	                    </xsl:element>                  
	                  </xsl:when>
	                </xsl:choose>
	                <xsl:if test="request-param[@name='startDate'] != '' and 
					        (request-param[@name='startDate'] != $desiredDate)">
	                 <!-- Tariff option startDate -->
	                 <xsl:element name="CcmFifConfiguredValueCont">
	                   <xsl:element name="service_char_code">V0200</xsl:element>
	                   <xsl:element name="data_type">STRING</xsl:element>
	                   <xsl:element name="configured_value">
	                     <xsl:value-of select="request-param[@name='startDate']"/>
	                   </xsl:element>
	                 </xsl:element>
	                </xsl:if>
	                <xsl:if test="request-param[@name='minimumDuration'] != ''">
	                 <!-- Tariff option minimumDuration -->
	                 <xsl:element name="CcmFifConfiguredValueCont">
	                   <xsl:element name="service_char_code">V0231</xsl:element>
	                   <xsl:element name="data_type">STRING</xsl:element>
	                   <xsl:element name="configured_value">
	                     <xsl:value-of select="request-param[@name='minimumDuration']"/>
	                   </xsl:element>
	                 </xsl:element>
	                </xsl:if>
	                <xsl:if test="request-param[@name='terminationDate'] != ''">
	                 <!-- Tariff option terminationDate -->
	                 <xsl:element name="CcmFifConfiguredValueCont">
	                   <xsl:element name="service_char_code">V0232</xsl:element>
	                   <xsl:element name="data_type">STRING</xsl:element>
	                   <xsl:element name="configured_value">
	                     <xsl:value-of select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
	                   </xsl:element>
	                 </xsl:element>
	                </xsl:if>
	                <xsl:for-each select="request-param-list[@name='additionalInfo']/request-param-list-item">
	                  <xsl:element name="CcmFifConfiguredValueCont">
	                    <xsl:element name="service_char_code">
	                      <xsl:value-of select="request-param[@name='serviceCharCode']"/>
	                    </xsl:element>
	                    <xsl:element name="data_type">
	                        <xsl:choose>
	                          <xsl:when test="request-param[@name='dataType'] != ''">
	                            <xsl:value-of select="request-param[@name='dataType']"/>
	                          </xsl:when>
	                          <xsl:otherwise>STRING</xsl:otherwise>
	                        </xsl:choose>                      
	                    </xsl:element>
		                <xsl:element name="configured_value">
	                        <xsl:choose>
			                  <xsl:when test="request-param[@name='serviceCharCode'] = 'V0946' or request-param[@name='serviceCharCode'] = 'V0947'">
				                <xsl:value-of select="dateutils:SOM2OPMDate(request-param[@name='value'])"/>
			                  </xsl:when>
			                  <xsl:otherwise>
				                <xsl:value-of select="request-param[@name='value']"/>
			                  </xsl:otherwise>
	                        </xsl:choose>                      
		                </xsl:element>
	                  </xsl:element>                  
	                </xsl:for-each>
	              </xsl:element>
	              <xsl:element name="sub_order_id">
	                <xsl:value-of select="$subOrderId"/>
	              </xsl:element>
	              <xsl:element name="detailed_reason_ref">
	                <xsl:element name="command_id">read_detailed_reason</xsl:element>
	                <xsl:element name="field_name">parameter_value</xsl:element>
	              </xsl:element>
	              <xsl:element name="provider_tracking_no">
	                <xsl:value-of select="$providerTrackingNumber"/>
	              </xsl:element>
	            </xsl:element>
	          </xsl:element>
          </xsl:if>

          <xsl:if test="$handleAsynchronousTermination = 'Y' and 
          				$terminationDateAsyncGTDesiredDate = 'Y' and 
          				request-param[@name='terminationDate'] != ''">
				
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
						<xsl:element name="short_description">Kündigungsdatum gesetzt</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>Kündigungsdatum </xsl:text> 
							<xsl:value-of select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
							<xsl:text> gesetzt für Tarifoption </xsl:text> 
							<xsl:value-of select="request-param[@name='serviceCode']"/>
							<xsl:text> von Hauptdienst </xsl:text>
							<xsl:value-of select="$serviceSubscriptionId"/>
							<xsl:text>&#xA;TransactionID: </xsl:text>
							<xsl:value-of select="../../request-param[@name='transactionID']"/>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="../../request-param[@name='clientName']"/>
							<xsl:text>)</xsl:text>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>add_service_</xsl:text>
								<xsl:value-of select="position()"/>	
							</xsl:element>
							<xsl:element name="field_name">service_added</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				
            <!-- create asynchronous termination fif request -->
             <xsl:element name="CcmFifCreateFifRequestCmd">
                   <xsl:element name="command_id">
                     <xsl:text>create_fif_request_tTO_</xsl:text>
                     <xsl:value-of select="position()"/>
                   </xsl:element>
               <xsl:element name="CcmFifCreateFifRequestInCont">
                 <xsl:element name="action_name">terminateTariffOption</xsl:element>
                 <xsl:element name="due_date">
                   <xsl:value-of select="request-param[@name='terminationDate']"/>
                 </xsl:element>
                 <xsl:element name="dependent_transaction_id">dummy</xsl:element>
                 <xsl:element name="priority">5</xsl:element>
                 <xsl:element name="bypass_command">N</xsl:element>
                 <xsl:element name="external_system_id_ref">
                   <xsl:element name="command_id">find_main_service</xsl:element>
                   <xsl:element name="field_name">service_subscription_id</xsl:element>
                 </xsl:element>
                 <xsl:element name="request_param_list">
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">customerNumber</xsl:element>
                     <xsl:element name="parameter_value_ref">
                       <xsl:element name="command_id">find_main_service</xsl:element>
                       <xsl:element name="field_name">customer_number</xsl:element>
                     </xsl:element>
                   </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                     <xsl:element name="parameter_value_ref">
                       <xsl:element name="command_id">
                         <xsl:text>add_service_</xsl:text>
                         <xsl:value-of select="position()"/>
                       </xsl:element>
                       <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                   </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">serviceCode</xsl:element>
                     <xsl:element name="parameter_value">
                       <xsl:value-of select="$serviceCode"/>
                     </xsl:element>
                   </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">terminationDate</xsl:element>
                     <xsl:element name="parameter_value">
                       <xsl:value-of select="request-param[@name='terminationDate']"/>
                     </xsl:element>
                   </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">handleContributingItem</xsl:element>
                     <xsl:element name="parameter_value">
                       <xsl:value-of select="request-param[@name='handleContributingItem']"/>
                     </xsl:element>
                   </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">OMTSOrderID</xsl:element>
                     <xsl:element name="parameter_value">
                       <xsl:value-of select="$OMTSOrderID"/>
                     </xsl:element>
                   </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">reason</xsl:element>
                     <xsl:element name="parameter_value">
                       <xsl:value-of select="$reason"/>
                     </xsl:element>
                   </xsl:element>
                 </xsl:element>
                   <xsl:element name="process_ind_ref">
                     <xsl:element name="command_id">
                       <xsl:text>add_service_</xsl:text>
                       <xsl:value-of select="position()"/>
                     </xsl:element>
                     <xsl:element name="field_name">service_added</xsl:element>
                   </xsl:element>
   					 <xsl:element name="required_process_ind">Y</xsl:element>
               </xsl:element>
             </xsl:element>

          </xsl:if>

          <xsl:if test="request-param[@name='handleSelectedDestination'] = 'Y' and request-param[@name='targetPhoneNumber'] != ''">
            <!-- Find Price Plan with selected destination -->      
            <xsl:element name="CcmFifFindPricePlanSubsCmd">
              <xsl:element name="command_id">
                <xsl:text>find_pps_</xsl:text>
                <xsl:value-of select="position()"/>
              </xsl:element>
              <xsl:element name="CcmFifFindPricePlanSubsInCont">
                <xsl:element name="service_subscription_id_ref">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$contributingItemDate"/>
                </xsl:element>                  
                <xsl:element name="selected_destination_ind">Y</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_added</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>

            <!-- add selected destination -->
            <xsl:element name="CcmFifConfigurePPSCmd">
              <xsl:element name="command_id">
                <xsl:text>config_pps_</xsl:text>
                <xsl:value-of select="position()"/>              
              </xsl:element>
              <xsl:element name="CcmFifConfigurePPSInCont">
                <xsl:element name="price_plan_subs_list_ref">
                  <xsl:element name="command_id">
                    <xsl:text>find_pps_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">price_plan_subs_list</xsl:element>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$contributingItemDate"/>
                </xsl:element>                  
                <xsl:element name="selected_destinations_list">
                  <xsl:element name="CcmFifSelectedDestCont">
                    <xsl:element name="begin_number">
                      <xsl:value-of select="request-param[@name='targetPhoneNumber']"/>
                    </xsl:element>
                    <xsl:element name="start_date">
                      <xsl:value-of select="$contributingItemDate"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_added</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>

          <xsl:if test="request-param[@name='handleContributingItem'] = 'Y'">
  
            <!-- Add contributing item, if the feature is a tariff option or country service -->
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
              <xsl:element name="command_id">
                <xsl:text>add_contributing_item_</xsl:text>
                <xsl:value-of select="position()"/>
              </xsl:element>
              <xsl:element name="CcmFifAddModifyContributingItemInCont">
                <xsl:element name="product_subscription_ref">
                  <xsl:element name="command_id">find_main_service</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_code">
                  <xsl:value-of select="$serviceCode"/>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$contributingItemDate"/>
                </xsl:element>
                <xsl:element name="contributing_item_list">
                  <xsl:element name="CcmFifContributingItem">                  
                    <xsl:element name="supported_object_type_rd">
                      <xsl:choose>
                        <xsl:when test="request-param[@name='contributingItemType'] != ''">
                          <xsl:value-of select="request-param[@name='contributingItemType']"/>
                        </xsl:when>
                        <xsl:otherwise>SERVICE_SUBSC</xsl:otherwise>
                      </xsl:choose>
                    </xsl:element>
                    <xsl:element name="start_date">
                      <xsl:value-of select="$contributingItemDate"/>
                    </xsl:element>
                    <xsl:choose>
                      <xsl:when test="request-param[@name='contributingItemType'] = 'PRODUCT_SUBSC'">
                        <xsl:element name="product_subscription_ref">
                          <xsl:element name="command_id">find_main_service</xsl:element>
                          <xsl:element name="field_name">product_subscription_id</xsl:element>
                        </xsl:element>                          
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:element name="service_subscription_ref">
                          <xsl:element name="command_id">find_main_service</xsl:element>
                          <xsl:element name="field_name">service_subscription_id</xsl:element>
                        </xsl:element>                          
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                </xsl:element>
    						<xsl:element name="process_ind_ref">
    							<xsl:element name="command_id">
    								<xsl:text>add_service_</xsl:text>
    								<xsl:value-of select="position()"/>
    							</xsl:element>
    							<xsl:element name="field_name">service_added</xsl:element>
    						</xsl:element>
    						<xsl:element name="required_process_ind">Y</xsl:element>
                <xsl:element name="no_price_plan_error">N</xsl:element>
                <xsl:element name="ignore_contributing_item_ind">Y</xsl:element>
                 
              </xsl:element>
            </xsl:element>
       
              
            <xsl:if test="$isMovedService != 'Y'">
              <!--  Get Orderform data  -->
              <xsl:element name="CcmFifGetOrderFormDataCmd">
                <xsl:element name="command_id">
                  <xsl:text>get_of_data_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="CcmFifGetOrderFormDataInCont">
                  <xsl:element name="contract_number_ref">
                    <xsl:element name="command_id">find_main_service</xsl:element>
                    <xsl:element name="field_name">contract_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">
                      <xsl:text>add_contributing_item_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">contributing_item_added</xsl:element>
                  </xsl:element>
                  <xsl:element name="target_state">APPROVED</xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>
                </xsl:element>
              </xsl:element>


			<xsl:choose>
			
				<xsl:when test="request-param[@name='workflowType'] != 'COM-OPM-FIF'">
	              <xsl:element name="CcmFifCreateFifRequestCmd">
	                <xsl:element name="command_id">create_fif_request_1</xsl:element>
	                <xsl:element name="CcmFifCreateFifRequestInCont">
	                  <xsl:element name="action_name">createContributingItem</xsl:element>
	                  <xsl:element name="due_date">
	                    <xsl:value-of select="$contributingItemDate"/>
	                  </xsl:element>
	                  <xsl:element name="dependent_transaction_id_ref">
	                    <xsl:element name="command_id">
	                      <xsl:text>get_of_data_</xsl:text>
	                      <xsl:value-of select="position()"/>
	                    </xsl:element>
	                    <xsl:element name="field_name">pending_fif_transaction_id</xsl:element>
	                  </xsl:element>
	                  <xsl:element name="priority">5</xsl:element>
	                  <xsl:element name="bypass_command">N</xsl:element>
	                  <xsl:element name="external_system_id_ref">
	                    <xsl:element name="command_id">find_main_service</xsl:element>
	                    <xsl:element name="field_name">customer_number</xsl:element>
	                  </xsl:element>
	                  <xsl:element name="request_param_list">
	                    <xsl:element name="CcmFifParameterValueCont">
	                      <xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
	                      <xsl:element name="parameter_value_ref">
	                        <xsl:element name="command_id">find_main_service</xsl:element>
	                        <xsl:element name="field_name">product_subscription_id</xsl:element>
	                      </xsl:element>
	                    </xsl:element>
	                    <xsl:element name="CcmFifParameterValueCont">
	                      <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
	                      <xsl:element name="parameter_value_ref">
	                        <xsl:element name="command_id">find_main_service</xsl:element>
	                        <xsl:element name="field_name">service_subscription_id</xsl:element>
	                      </xsl:element>
	                    </xsl:element>
	                    <xsl:element name="CcmFifParameterValueCont">
	                      <xsl:element name="parameter_name">SERVICE_CODE</xsl:element>
	                      <xsl:element name="parameter_value">
	                        <xsl:value-of select="$serviceCode"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <xsl:element name="CcmFifParameterValueCont">
	                      <xsl:element name="parameter_name">CONTRIBUTING_TYPE</xsl:element>
	                      <xsl:element name="parameter_value">SERVICE_SUBSC</xsl:element>
	                    </xsl:element>
	                    <xsl:element name="CcmFifParameterValueCont">
	                      <xsl:element name="parameter_name">EFFECTIVE_DATE</xsl:element>
	                      <xsl:element name="parameter_value">
	                        <xsl:value-of select="$contributingItemDate"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <xsl:element name="CcmFifParameterValueCont">
	                      <xsl:element name="parameter_name">START_DATE</xsl:element>
	                      <xsl:element name="parameter_value">
	                        <xsl:value-of select="$contributingItemDate"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:element>
	                  <xsl:element name="process_ind_ref">
	                    <xsl:element name="command_id">
	                      <xsl:text>add_contributing_item_</xsl:text>
	                      <xsl:value-of select="position()"/>
	                    </xsl:element>
	                    <xsl:element name="field_name">contributing_item_added</xsl:element>
	                  </xsl:element>
	                  <xsl:element name="required_process_ind">N</xsl:element>
	                </xsl:element>
	              </xsl:element>
				</xsl:when>
			
				<xsl:otherwise>
				  <!-- ContributingItem couldn't be created, most likely because the tariff 
				  hasn't been applied yet (i.e. new pricePlanSubscriptions are not created yet).
				  A later transaction in the requestList will take care of that, but needs to know 
				  which contributedItems have to be created. -->				
				  <xsl:element name="CcmFifCreateExternalNotificationCmd">
			        <xsl:element name="command_id">
			        	<xsl:text>contributingItemNotification</xsl:text>
			        	<xsl:value-of select="position()"/>	
			        </xsl:element>
			        <xsl:element name="CcmFifCreateExternalNotificationInCont">
			          <xsl:element name="effective_date">
			            <xsl:value-of select="$today"/>
			          </xsl:element>
			          <xsl:element name="transaction_id">
			            <xsl:value-of select="$requestListId"/>
			            <xsl:text>-</xsl:text>
			            <xsl:value-of select="$serviceSubscriptionId"/>
			            <xsl:text>-</xsl:text>
			            <xsl:value-of select="request-param[@name='serviceCode']"/>
			          </xsl:element>
			          <xsl:element name="processed_indicator">Y</xsl:element>
			          <xsl:element name="notification_action_name">createContributingItem</xsl:element>
			          <xsl:element name="target_system">FIF</xsl:element>
			          <xsl:element name="parameter_value_list">
			            <xsl:element name="CcmFifParameterValueCont">
			              <xsl:element name="parameter_name">productSubscriptionId</xsl:element>
			              <xsl:element name="parameter_value_ref">
                            <xsl:element name="command_id">find_main_service</xsl:element>
                            <xsl:element name="field_name">product_subscription_id</xsl:element>
			              </xsl:element>
			            </xsl:element>
			            <xsl:element name="CcmFifParameterValueCont">
			              <xsl:element name="parameter_name">startDate</xsl:element>
			              <xsl:element name="parameter_value">
                            <xsl:value-of select="$contributingItemDate"/>
			              </xsl:element>
			            </xsl:element>
			            <xsl:element name="CcmFifParameterValueCont">
			              <xsl:element name="parameter_name">useProductSubscriptionId</xsl:element>
			              <xsl:element name="parameter_value_ref">
			                <xsl:element name="command_id">find_counting_services</xsl:element>
                        	<xsl:element name="field_name">service_found</xsl:element>
			              </xsl:element>
			            </xsl:element>
			          </xsl:element>
	                  <xsl:element name="process_ind_ref">
	                    <xsl:element name="command_id">
	                      <xsl:text>add_contributing_item_</xsl:text>
	                      <xsl:value-of select="position()"/>
	                    </xsl:element>
	                    <xsl:element name="field_name">contributing_item_added</xsl:element>
	                  </xsl:element>
	                  <xsl:element name="required_process_ind">N</xsl:element>
			        </xsl:element>
			      </xsl:element>								
				</xsl:otherwise>
			</xsl:choose>

            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>

      <!-- subscribe when configuredServiceList exist -->
      <xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
        
        <xsl:variable name="serviceCode">
          <xsl:value-of select="request-param[@name='serviceCode']"/>
        </xsl:variable>
        <xsl:variable name="conditionId">
          <xsl:value-of select="request-param[@name='conditionId']"/>
        </xsl:variable>
        <xsl:variable name="conditionName">
          <xsl:value-of select="request-param[@name='conditionName']"/>
        </xsl:variable>

        <xsl:variable name="terminationDateAsyncGTDesiredDate" >
          <xsl:choose>          
            <xsl:when test="request-param[@name='terminationDate'] = ''">
              <xsl:text>Y</xsl:text>
            </xsl:when>          
            <xsl:when test="request-param[@name='terminationDate'] != ''
              and dateutils:compareString(request-param[@name='terminationDate'], $desiredDate) = '1'">
              <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>N</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="configuredInExisting">
         <xsl:call-template name="serviceExistsInList">
         	<xsl:with-param name="service" select="."/>
         	<xsl:with-param name="list" select="../../request-param-list[@name='existingServiceList']"/>            	
         </xsl:call-template>
        </xsl:variable>
            
        <!-- subscribe if configuredService list exist and cloned and service not in existingServiceList -->
        <xsl:if test="$action != 'remove' and
          ($isMovedService = 'Y' or $configuredInExisting = 'false')">
          
          <xsl:if test="$serviceCode = 'V0850' or $serviceCode = 'V0854' or $serviceCode = 'V0855'">
            <!-- get GCI entry for articleNumber to retrieve the billing name -->
            <xsl:element name="CcmFifValidateGeneralCodeItemCmd">
              <xsl:element name="command_id">find_article_name</xsl:element>
              <xsl:element name="CcmFifValidateGeneralCodeItemInCont">
                <xsl:element name="group_code">HW_ART_DES</xsl:element>
                <xsl:element name="value">
                  <xsl:value-of select="request-param[@name='articleNumber']"/>
                </xsl:element>
                <xsl:element name="raise_error_if_invalid">Y</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          

          <!-- Add Feature Service -->
          <xsl:if test="$handleAsynchronousTermination != 'Y' or
          				$handleAsynchronousTermination = 'Y' and $terminationDateAsyncGTDesiredDate = 'Y'">
	          <xsl:element name="CcmFifAddServiceSubsCmd">
	            <xsl:element name="command_id">
	              <xsl:text>add_service_</xsl:text>
	              <xsl:value-of select="position()"/>
	            </xsl:element>
	            <xsl:element name="CcmFifAddServiceSubsInCont">
	              <xsl:element name="product_subscription_ref">
	                <xsl:element name="command_id">find_main_service</xsl:element>
	                <xsl:element name="field_name">product_subscription_id</xsl:element>
	              </xsl:element>
	              <xsl:element name="service_code">
	                <xsl:value-of select="$serviceCode"/>
	              </xsl:element>
	              <xsl:element name="sales_organisation_number">
	                <xsl:value-of select="$salesOrganisationNumber"/>
	              </xsl:element>
	              <xsl:element name="sales_organisation_number_vf">
	                <xsl:value-of select="$salesOrganisationNumberVF"/>
	              </xsl:element>
	              <xsl:element name="parent_service_subs_ref">
	                <xsl:element name="command_id">
	                  <xsl:choose>
	                    <xsl:when test="$parentServiceCode != ''">find_parent_service</xsl:when>
	                    <xsl:otherwise>find_main_service</xsl:otherwise>
	                  </xsl:choose>
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
	              <xsl:element name="account_number_ref">
	                <xsl:element name="command_id">find_main_service</xsl:element>
	                <xsl:element name="field_name">account_number</xsl:element>
	              </xsl:element>
	              <xsl:element name="order_date">
	                <xsl:value-of select="$orderDate"/>
	              </xsl:element>
	              <xsl:element name="ignore_if_service_exist">
	                <xsl:value-of select="$ignoreDuplicates"/>
	              </xsl:element>                            
	              <xsl:element name="use_current_pc_version">Y</xsl:element>              
	              <xsl:element name="ignore_wrong_service_code">
	                <xsl:choose>
	                  <xsl:when test="$ignoreWrongServiceCode != ''">
	                    <xsl:value-of select="$ignoreWrongServiceCode"/>
	                  </xsl:when>
	                  <xsl:otherwise>
	                    <xsl:value-of select="$isMovedService"/>
	                  </xsl:otherwise>
	                </xsl:choose>
	              </xsl:element>
	              <xsl:element name="service_characteristic_list">
	                <xsl:choose>
	                  <xsl:when test="$serviceCode = 'V0303'">
	                    <!-- DelightDescription -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0212</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Delightcode -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0211</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- DelightEnddate -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0213</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='endDate']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0045'">
	                    <!-- Kondition einmalig -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0095</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition einmalig ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0160</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0046'">
	                    <!-- Kondition monatlich -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0096</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition monatlich ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0161</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Startdatum -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0200</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='startDate']"/>
	                      </xsl:element>
	                    </xsl:element>                    
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V004A'">
	                    <!-- Sonderprämien -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0113</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Sonderprämie ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0209</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Sonderprämie Gutscheincode -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0210</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='specialBonusCode']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0317'">
	                    <!-- Kondition einmalig -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0192</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition einmalig ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0194</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0318'">
	                    <!-- Kondition monatlich -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0193</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionName']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Kondition monatlich ID -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0195</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='conditionId']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Startdatum -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0200</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='startDate']"/>
	                      </xsl:element>
	                    </xsl:element>                    
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0850' or $serviceCode = 'V0854' or $serviceCode = 'V0855'">
	                    <!-- Unterdrückung Einmalpreis -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0882</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:choose>
	                          <xsl:when test="request-param[@name='conditionName'] = 'Monatspreis mit Einmalpreisbefreiung'">Ja</xsl:when>
	                          <xsl:otherwise>Nein</xsl:otherwise>
	                        </xsl:choose>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Startdatum -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0200</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='startDate']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  	<xsl:choose>
		                  <xsl:when test="$serviceCode = 'V0854' or $serviceCode = 'V0855'">
		                    <!--  Hardware Artikelnummer Mietpreis -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V9004</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value">
		                        <xsl:choose>
		                      	  <xsl:when test="request-param[@name='conditionId'] = 'keine Mietgebühr'">
		                      	    <xsl:value-of select="request-param[@name='conditionId']"/>
		                      	  </xsl:when>
		                      	  <xsl:otherwise>
		                      	  	<xsl:value-of select="request-param[@name='articleNumber']"/>
		                      	  </xsl:otherwise>
		                        </xsl:choose>
		                      </xsl:element>
		                    </xsl:element>
		                    <!--  Hardware Bezeichnung Mietpreis -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V9005</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value_ref">
		                        <xsl:element name="command_id">find_article_name</xsl:element>
		                        <xsl:element name="field_name">description</xsl:element>
		                      </xsl:element>
		                    </xsl:element>                    
		                  </xsl:when>
		                  <xsl:when test="$serviceCode = 'V0850'">
		                    <!--  Hardware Artikelnummer -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V0880</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value">
		                        <xsl:value-of select="request-param[@name='articleNumber']"/>
		                      </xsl:element>
		                    </xsl:element>
		                    <!--  Hardware Bezeichnung -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">V0881</xsl:element>
		                      <xsl:element name="data_type">STRING</xsl:element>
		                      <xsl:element name="configured_value_ref">
		                        <xsl:element name="command_id">find_article_name</xsl:element>
		                        <xsl:element name="field_name">description</xsl:element>
		                      </xsl:element>
		                    </xsl:element>                    
		                    <!-- Anzahl -->
		                    <xsl:element name="CcmFifConfiguredValueCont">
		                      <xsl:element name="service_char_code">VI115</xsl:element>
		                      <xsl:element name="data_type">INTEGER</xsl:element>
		                      <xsl:element name="configured_value">
		                        <xsl:value-of select="request-param[@name='quantity']"/>
		                      </xsl:element>
		                    </xsl:element>                    
		                  </xsl:when>
		 				</xsl:choose>
	                  </xsl:when>
	                  <xsl:when test="request-param[@name='minPeriodDurationValue'] != ''">
	                    <!-- Vertragslaufzeit IP-Centrex -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">VI073</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
	                      </xsl:element>
	                    </xsl:element>
	                    <!-- Vertragslaufzeit -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">I120A</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:choose>
	                          <xsl:when test="request-param[@name='minPeriodDurationValue'] = '12'">1 Jahr</xsl:when>
	                          <xsl:when test="request-param[@name='minPeriodDurationValue'] = '24'">2 Jahre</xsl:when>
	                          <xsl:when test="request-param[@name='minPeriodDurationValue'] = '36'">3 Jahre</xsl:when>
	                        </xsl:choose>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="request-param[@name='hotSubscriptionIndicator'] != ''">
	                    <!-- TV Addons Hot Subscription -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">I1320</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='hotSubscriptionIndicator']"/>
	                      </xsl:element>
	                    </xsl:element>
	                  </xsl:when>
	                  <xsl:when test="$serviceCode = 'V0304'">
	                    <!-- Zielrufnummer -->
	                    <xsl:element name="CcmFifConfiguredValueCont">
	                      <xsl:element name="service_char_code">V0230</xsl:element>
	                      <xsl:element name="data_type">STRING</xsl:element>
	                      <xsl:element name="configured_value">
	                        <xsl:value-of select="request-param[@name='targetPhoneNumber']"/>
	                      </xsl:element>
	                    </xsl:element>                  
	                  </xsl:when>                
	                </xsl:choose>
	                <xsl:if test="request-param[@name='startDate'] != '' and 
					        (request-param[@name='startDate'] != $desiredDate)">
	                 <!-- Tariff option startDate -->
	                 <xsl:element name="CcmFifConfiguredValueCont">
	                   <xsl:element name="service_char_code">V0200</xsl:element>
	                   <xsl:element name="data_type">STRING</xsl:element>
	                   <xsl:element name="configured_value">
	                     <xsl:value-of select="request-param[@name='startDate']"/>
	                   </xsl:element>
	                 </xsl:element>
	                </xsl:if>
	                <xsl:if test="request-param[@name='minimumDuration'] != ''">
	                 <!-- Tariff option minimumDuration -->
	                 <xsl:element name="CcmFifConfiguredValueCont">
	                   <xsl:element name="service_char_code">V0231</xsl:element>
	                   <xsl:element name="data_type">STRING</xsl:element>
	                   <xsl:element name="configured_value">
	                     <xsl:value-of select="request-param[@name='minimumDuration']"/>
	                   </xsl:element>
	                 </xsl:element>
	                </xsl:if>
	                <xsl:if test="request-param[@name='terminationDate'] != ''">
	                 <!-- Tariff option terminationDate -->
	                 <xsl:element name="CcmFifConfiguredValueCont">
	                   <xsl:element name="service_char_code">V0232</xsl:element>
	                   <xsl:element name="data_type">STRING</xsl:element>
	                   <xsl:element name="configured_value">
	                     <xsl:value-of select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
	                   </xsl:element>
	                 </xsl:element>
	                </xsl:if>
	                <xsl:for-each select="request-param-list[@name='additionalInfo']/request-param-list-item">
	                  <xsl:element name="CcmFifConfiguredValueCont">
	                    <xsl:element name="service_char_code">
	                      <xsl:value-of select="request-param[@name='serviceCharCode']"/>
	                    </xsl:element>
	                    <xsl:element name="data_type">
	                        <xsl:choose>
	                          <xsl:when test="request-param[@name='dataType'] != ''">
	                            <xsl:value-of select="request-param[@name='dataType']"/>
	                          </xsl:when>
	                          <xsl:otherwise>STRING</xsl:otherwise>
	                        </xsl:choose>                      
	                    </xsl:element>
	                    <xsl:element name="configured_value">
	                        <xsl:choose>
			                  <xsl:when test="request-param[@name='serviceCharCode'] = 'V0946' or request-param[@name='serviceCharCode'] = 'V0947'">
				                <xsl:value-of select="dateutils:SOM2OPMDate(request-param[@name='value'])"/>
			                  </xsl:when>
			                  <xsl:otherwise>
				                <xsl:value-of select="request-param[@name='value']"/>
			                  </xsl:otherwise>
	                        </xsl:choose>                      
	                    </xsl:element>
	                  </xsl:element>                  
	                </xsl:for-each>
	              </xsl:element>
	              <xsl:element name="sub_order_id">
	                <xsl:value-of select="$subOrderId"/>
	              </xsl:element>
	              <xsl:element name="detailed_reason_ref">
	                <xsl:element name="command_id">read_detailed_reason</xsl:element>
	                <xsl:element name="field_name">parameter_value</xsl:element>
	              </xsl:element>
	              <xsl:element name="provider_tracking_no">
	                <xsl:value-of select="$providerTrackingNumber"/>
	              </xsl:element>
	            </xsl:element>
	          </xsl:element>
          </xsl:if>

          <xsl:if test="$handleAsynchronousTermination = 'Y' and 
          				$terminationDateAsyncGTDesiredDate = 'Y' and 
          				request-param[@name='terminationDate'] != ''">

				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
						<xsl:element name="short_description">Kündigungsdatum gesetzt</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>Kündigungsdatum </xsl:text> 
							<xsl:value-of select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
							<xsl:text> gesetzt für Tarifoption </xsl:text> 
							<xsl:value-of select="request-param[@name='serviceCode']"/>
							<xsl:text> von Hauptdienst </xsl:text>
							<xsl:value-of select="$serviceSubscriptionId"/>
							<xsl:text>&#xA;TransactionID: </xsl:text>
							<xsl:value-of select="../../request-param[@name='transactionID']"/>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="../../request-param[@name='clientName']"/>
							<xsl:text>)</xsl:text>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>add_service_</xsl:text>
								<xsl:value-of select="position()"/>	
							</xsl:element>
							<xsl:element name="field_name">service_added</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>


            <!-- create asynchronous termination fif request -->
            <xsl:element name="CcmFifCreateFifRequestCmd">
                    <xsl:element name="command_id">
                      <xsl:text>create_fif_request_tTO_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
              <xsl:element name="CcmFifCreateFifRequestInCont">
                <xsl:element name="action_name">terminateTariffOption</xsl:element>
                <xsl:element name="due_date">
                  <xsl:value-of select="request-param[@name='terminationDate']"/>
                </xsl:element>
                <xsl:element name="dependent_transaction_id">dummy</xsl:element>
                <xsl:element name="priority">5</xsl:element>
                <xsl:element name="bypass_command">N</xsl:element>
                <xsl:element name="external_system_id_ref">
                  <xsl:element name="command_id">find_main_service</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="request_param_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">customerNumber</xsl:element>
                    <xsl:element name="parameter_value_ref">
                      <xsl:element name="command_id">find_main_service</xsl:element>
                      <xsl:element name="field_name">customer_number</xsl:element>
                    </xsl:element>
                  </xsl:element>
                   <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                     <xsl:element name="parameter_value_ref">
                       <xsl:element name="command_id">
                         <xsl:text>add_service_</xsl:text>
                         <xsl:value-of select="position()"/>
                       </xsl:element>
                       <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                   </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">serviceCode</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$serviceCode"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">terminationDate</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='terminationDate']"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">handleContributingItem</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='handleContributingItem']"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">OMTSOrderID</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$OMTSOrderID"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">reason</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$reason"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">
                      <xsl:text>add_service_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_added</xsl:element>
                  </xsl:element>
  					 <xsl:element name="required_process_ind">Y</xsl:element>
              </xsl:element>
            </xsl:element>
			</xsl:if>


          <xsl:if test="request-param[@name='handleSelectedDestination'] = 'Y' and request-param[@name='targetPhoneNumber'] != ''">
            <!-- Find Price Plan with selected destination -->      
            <xsl:element name="CcmFifFindPricePlanSubsCmd">
              <xsl:element name="command_id">
                <xsl:text>find_pps_</xsl:text>
                <xsl:value-of select="position()"/>
              </xsl:element>
              <xsl:element name="CcmFifFindPricePlanSubsInCont">
                <xsl:element name="service_subscription_id_ref">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$contributingItemDate"/>
                </xsl:element>                  
                <xsl:element name="selected_destination_ind">Y</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_added</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>

            <!-- add selected destination -->
            <xsl:element name="CcmFifConfigurePPSCmd">
              <xsl:element name="command_id">
                <xsl:text>config_pps_</xsl:text>
                <xsl:value-of select="position()"/>              
              </xsl:element>
              <xsl:element name="CcmFifConfigurePPSInCont">
                <xsl:element name="price_plan_subs_list_ref">
                  <xsl:element name="command_id">
                    <xsl:text>find_pps_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">price_plan_subs_list</xsl:element>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$contributingItemDate"/>
                </xsl:element>                  
                <xsl:element name="selected_destinations_list">
                  <xsl:element name="CcmFifSelectedDestCont">
                    <xsl:element name="begin_number">
                      <xsl:value-of select="request-param[@name='targetPhoneNumber']"/>
                    </xsl:element>
                    <xsl:element name="start_date">
                      <xsl:value-of select="$contributingItemDate"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_added</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          
          <xsl:if test="request-param[@name='handleContributingItem'] = 'Y'">
              
            <!-- Add contributing item, if the feature is a tariff option or country service -->
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
              <xsl:element name="command_id">
                <xsl:text>add_contributing_item_</xsl:text>
                <xsl:value-of select="position()"/>
              </xsl:element>
              <xsl:element name="CcmFifAddModifyContributingItemInCont">
                <xsl:element name="product_subscription_ref">
                  <xsl:element name="command_id">find_main_service</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_code">
                  <xsl:value-of select="$serviceCode"/>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$contributingItemDate"/>
                </xsl:element>
                <xsl:element name="contributing_item_list">
                  <xsl:element name="CcmFifContributingItem">
                    <xsl:element name="supported_object_type_rd">
                      <xsl:choose>
                        <xsl:when test="request-param[@name='contributingItemType'] != ''">
                          <xsl:value-of select="request-param[@name='contributingItemType']"/>
                        </xsl:when>
                        <xsl:otherwise>SERVICE_SUBSC</xsl:otherwise>
                      </xsl:choose>
                    </xsl:element>
                    <xsl:element name="start_date">
                      <xsl:value-of select="$contributingItemDate"/>
                    </xsl:element>
                    <xsl:choose>
                      <xsl:when test="request-param[@name='contributingItemType'] = 'PRODUCT_SUBSC'">
                        <xsl:element name="product_subscription_ref">
                          <xsl:element name="command_id">find_main_service</xsl:element>
                          <xsl:element name="field_name">product_subscription_id</xsl:element>
                        </xsl:element>                          
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:element name="service_subscription_ref">
                          <xsl:element name="command_id">find_main_service</xsl:element>
                          <xsl:element name="field_name">service_subscription_id</xsl:element>
                        </xsl:element>                          
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                </xsl:element>
    						<xsl:element name="process_ind_ref">
    							<xsl:element name="command_id">
    								<xsl:text>add_service_</xsl:text>
    								<xsl:value-of select="position()"/>
    							</xsl:element>
    							<xsl:element name="field_name">service_added</xsl:element>
    						</xsl:element>
    						<xsl:element name="required_process_ind">Y</xsl:element>
                <xsl:element name="no_price_plan_error">N</xsl:element>
                <xsl:element name="ignore_contributing_item_ind">Y</xsl:element>
                 
              </xsl:element>
            </xsl:element>
              

            <xsl:if test="$isMovedService != 'Y'">
              <!--  Get Orderform data  -->
              <xsl:element name="CcmFifGetOrderFormDataCmd">
                <xsl:element name="command_id">
                  <xsl:text>get_of_data_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="CcmFifGetOrderFormDataInCont">
                  <xsl:element name="contract_number_ref">
                    <xsl:element name="command_id">find_main_service</xsl:element>
                    <xsl:element name="field_name">contract_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">
                      <xsl:text>add_contributing_item_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">contributing_item_added</xsl:element>
                  </xsl:element>
                  <xsl:element name="target_state">APPROVED</xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>
                </xsl:element>
              </xsl:element>
			
				<xsl:choose>
				
					<xsl:when test="request-param[@name='workflowType'] != 'COM-OPM-FIF'">
		              <xsl:element name="CcmFifCreateFifRequestCmd">
		                <xsl:element name="command_id">create_fif_request_1</xsl:element>
		                <xsl:element name="CcmFifCreateFifRequestInCont">
		                  <xsl:element name="action_name">createContributingItem</xsl:element>
		                  <xsl:element name="due_date">
		                    <xsl:value-of select="$contributingItemDate"/>
		                  </xsl:element>
		                  <xsl:element name="dependent_transaction_id_ref">
		                    <xsl:element name="command_id">
		                      <xsl:text>get_of_data_</xsl:text>
		                      <xsl:value-of select="position()"/>
		                    </xsl:element>
		                    <xsl:element name="field_name">pending_fif_transaction_id</xsl:element>
		                  </xsl:element>
		                  <xsl:element name="priority">5</xsl:element>
		                  <xsl:element name="bypass_command">N</xsl:element>
		                  <xsl:element name="external_system_id_ref">
		                    <xsl:element name="command_id">find_main_service</xsl:element>
		                    <xsl:element name="field_name">customer_number</xsl:element>
		                  </xsl:element>
		                  <xsl:element name="request_param_list">
		                    <xsl:element name="CcmFifParameterValueCont">
		                      <xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
		                      <xsl:element name="parameter_value_ref">
		                        <xsl:element name="command_id">find_main_service</xsl:element>
		                        <xsl:element name="field_name">product_subscription_id</xsl:element>
		                      </xsl:element>
		                    </xsl:element>
		                    <xsl:element name="CcmFifParameterValueCont">
		                      <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
		                      <xsl:element name="parameter_value_ref">
		                        <xsl:element name="command_id">find_main_service</xsl:element>
		                        <xsl:element name="field_name">service_subscription_id</xsl:element>
		                      </xsl:element>
		                    </xsl:element>
		                    <xsl:element name="CcmFifParameterValueCont">
		                      <xsl:element name="parameter_name">SERVICE_CODE</xsl:element>
		                      <xsl:element name="parameter_value">
		                        <xsl:value-of select="$serviceCode"/>
		                      </xsl:element>
		                    </xsl:element>
		                    <xsl:element name="CcmFifParameterValueCont">
		                      <xsl:element name="parameter_name">CONTRIBUTING_TYPE</xsl:element>
		                      <xsl:element name="parameter_value">SERVICE_SUBSC</xsl:element>
		                    </xsl:element>
		                    <xsl:element name="CcmFifParameterValueCont">
		                      <xsl:element name="parameter_name">EFFECTIVE_DATE</xsl:element>
		                      <xsl:element name="parameter_value">
		                        <xsl:value-of select="$contributingItemDate"/>
		                      </xsl:element>
		                    </xsl:element>
		                    <xsl:element name="CcmFifParameterValueCont">
		                      <xsl:element name="parameter_name">START_DATE</xsl:element>
		                      <xsl:element name="parameter_value">
		                        <xsl:value-of select="$contributingItemDate"/>
		                      </xsl:element>
		                    </xsl:element>
		                  </xsl:element>
		                  <xsl:element name="process_ind_ref">
		                    <xsl:element name="command_id">
		                      <xsl:text>add_contributing_item_</xsl:text>
		                      <xsl:value-of select="position()"/>
		                    </xsl:element>
		                    <xsl:element name="field_name">contributing_item_added</xsl:element>
		                  </xsl:element>
		                  <xsl:element name="required_process_ind">N</xsl:element>
		                </xsl:element>
		              </xsl:element>
					</xsl:when>
				
					<xsl:otherwise>
					  <!-- ContributingItem couldn't be created, most likely because the tariff 
					  hasn't been applied yet (i.e. new pricePlanSubscriptions are not created yet).
					  A later transaction in the requestList will take care of that, but needs to know 
					  which contributedItems have to be created. -->				
					  <xsl:element name="CcmFifCreateExternalNotificationCmd">
				        <xsl:element name="command_id">
				        	<xsl:text>contributingItemNotification</xsl:text>
				        	<xsl:value-of select="position()"/>	
				        </xsl:element>
				        <xsl:element name="CcmFifCreateExternalNotificationInCont">
				          <xsl:element name="effective_date">
				            <xsl:value-of select="$today"/>
				          </xsl:element>
				          <xsl:element name="transaction_id">
				            <xsl:value-of select="$requestListId"/>
				            <xsl:text>-</xsl:text>
				            <xsl:value-of select="$serviceSubscriptionId"/>
				            <xsl:text>-</xsl:text>
				            <xsl:value-of select="request-param[@name='serviceCode']"/>
				          </xsl:element>
				          <xsl:element name="processed_indicator">Y</xsl:element>
				          <xsl:element name="notification_action_name">createContributingItem</xsl:element>
				          <xsl:element name="target_system">FIF</xsl:element>
				          <xsl:element name="parameter_value_list">
				            <xsl:element name="CcmFifParameterValueCont">
				              <xsl:element name="parameter_name">productSubscriptionId</xsl:element>
				              <xsl:element name="parameter_value_ref">
	                            <xsl:element name="command_id">find_main_service</xsl:element>
	                            <xsl:element name="field_name">product_subscription_id</xsl:element>
				              </xsl:element>
				            </xsl:element>
				            <xsl:element name="CcmFifParameterValueCont">
				              <xsl:element name="parameter_name">startDate</xsl:element>
				              <xsl:element name="parameter_value">
	                            <xsl:value-of select="$contributingItemDate"/>
				              </xsl:element>
				            </xsl:element>
				            <xsl:element name="CcmFifParameterValueCont">
				              <xsl:element name="parameter_name">useProductSubscriptionId</xsl:element>
				              <xsl:element name="parameter_value_ref">
				                <xsl:element name="command_id">find_counting_services_2</xsl:element>
	                        	<xsl:element name="field_name">service_found</xsl:element>
				              </xsl:element>
				            </xsl:element>
				          </xsl:element>
		                  <xsl:element name="process_ind_ref">
		                    <xsl:element name="command_id">
		                      <xsl:text>add_contributing_item_</xsl:text>
		                      <xsl:value-of select="position()"/>
		                    </xsl:element>
		                    <xsl:element name="field_name">contributing_item_added</xsl:element>
		                  </xsl:element>
		                  <xsl:element name="required_process_ind">N</xsl:element>
				        </xsl:element>
				      </xsl:element>								
					</xsl:otherwise>
				</xsl:choose>			
			
            </xsl:if>
          </xsl:if>
        </xsl:if>

        <!-- reconfigure if exists in existingServiceList for not cloned and asynchronous termination -->
        <xsl:if test="
        	$handleAsynchronousTermination = 'Y' and 
        	$action != 'remove' and 
        	$isMovedService = 'N' and 
        	$configuredInExisting = 'true' and
			request-param[@name='terminationDate'] != 
				../../request-param-list[@name='existingServiceList']/request-param-list-item[
	       			request-param[@name='serviceCode'] = $serviceCode]/
    	   			request-param[@name='terminationDate']">

   			<!-- find the service for reconfiguration -->
       		<xsl:element name="CcmFifFindServiceSubsCmd">
       			<xsl:element name="command_id">
		        	<xsl:text>find_service_for_reconf_</xsl:text>
		        	<xsl:value-of select="position()"/>	
				</xsl:element>
       			<xsl:element name="CcmFifFindServiceSubsInCont">
     					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
     					</xsl:element>
     					<xsl:element name="service_code">
						<xsl:value-of select="$serviceCode"/>
					</xsl:element>
					<xsl:element name="target_state">SUBSCRIBED</xsl:element>
       			</xsl:element>
       		</xsl:element>

     			<!-- reconfigure serivce subscription -->
     		<xsl:element name="CcmFifReconfigServiceCmd">
		        <xsl:element name="command_id">
		        	<xsl:text>reconf_service_</xsl:text>
		        	<xsl:value-of select="position()"/>	
		        </xsl:element>
     				<xsl:element name="CcmFifReconfigServiceInCont">
     					<xsl:element name="service_subscription_ref">
   			        <xsl:element name="command_id">
   			        	<xsl:text>find_service_for_reconf_</xsl:text>
   			        	<xsl:value-of select="position()"/>	
   			        </xsl:element>
     						<xsl:element name="field_name">service_subscription_id</xsl:element>
     					</xsl:element>
     					<xsl:element name="desired_date">
     						<xsl:value-of select="$today"/>
     					</xsl:element>
     					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
     					<xsl:element name="reason_rd">
     						<xsl:value-of select="$reason"/>
     					</xsl:element>
     					<xsl:element name="service_characteristic_list">
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0232</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:choose>
									<xsl:when test="request-param[@name='terminationDate'] = ''">**NULL**</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>	
									</xsl:otherwise>
								</xsl:choose>
						    </xsl:element>
						</xsl:element>
     					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">
							<xsl:text>find_service_for_reconf_</xsl:text>
							<xsl:value-of select="position()"/>	
						</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
     				</xsl:element>
     			</xsl:element>
     			
     			<xsl:if test="request-param[@name='terminationDate'] = ''">
      			<!-- create contact for deletion of termination date-->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
						<xsl:element name="short_description">Kündigungsdatum gelöscht</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>Kündigungsdatum gelöscht für Tarifoption </xsl:text> 
							<xsl:value-of select="request-param[@name='serviceCode']"/>
							<xsl:text> von Hauptdienst </xsl:text>
							<xsl:value-of select="$serviceSubscriptionId"/>
							<xsl:text>&#xA;TransactionID: </xsl:text>
							<xsl:value-of select="../../request-param[@name='transactionID']"/>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="../../request-param[@name='clientName']"/>
							<xsl:text>)</xsl:text>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>find_service_for_reconf_</xsl:text>
								<xsl:value-of select="position()"/>	
							</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
     		</xsl:if>

            <!-- create asynchronous termination fif request -->
            <xsl:if test="request-param[@name='terminationDate'] != ''">
            	      			<!-- create contact for deletion of termination date-->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
						<xsl:element name="short_description">Kündigungsdatum gesetzt</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>Kündigungsdatum </xsl:text> 
							<xsl:value-of select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
							<xsl:text> gesetzt für Tarifoption </xsl:text> 
							<xsl:value-of select="request-param[@name='serviceCode']"/>
							<xsl:text> von Hauptdienst </xsl:text>
							<xsl:value-of select="$serviceSubscriptionId"/>
							<xsl:text>&#xA;TransactionID: </xsl:text>
							<xsl:value-of select="../../request-param[@name='transactionID']"/>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="../../request-param[@name='clientName']"/>
							<xsl:text>)</xsl:text>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>find_service_for_reconf_</xsl:text>
								<xsl:value-of select="position()"/>	
							</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
            
            
              <xsl:element name="CcmFifCreateFifRequestCmd">
                  <xsl:element name="command_id">
                    <xsl:text>create_fif_request_tTO_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                <xsl:element name="CcmFifCreateFifRequestInCont">
                  <xsl:element name="action_name">terminateTariffOption</xsl:element>
                  <xsl:element name="due_date">
                    <xsl:value-of select="request-param[@name='terminationDate']"/>
                  </xsl:element>
                  <xsl:element name="dependent_transaction_id">dummy</xsl:element>
                  <xsl:element name="priority">5</xsl:element>
                  <xsl:element name="bypass_command">N</xsl:element>
                  <xsl:element name="external_system_id_ref">
                    <xsl:element name="command_id">find_main_service</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="request_param_list">
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">customerNumber</xsl:element>
                      <xsl:element name="parameter_value_ref">
                        <xsl:element name="command_id">find_main_service</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                      <xsl:element name="parameter_value_ref">
                        <xsl:element name="command_id">
                          <xsl:text>find_service_for_reconf_</xsl:text>
                          <xsl:value-of select="position()"/>
                        </xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">serviceCode</xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="$serviceCode"/>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">terminationDate</xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="request-param[@name='terminationDate']"/>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">handleContributingItem</xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="request-param[@name='handleContributingItem']"/>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">OMTSOrderID</xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="$OMTSOrderID"/>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">reason</xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="$reason"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">
                      <xsl:text>find_service_for_reconf_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_found</xsl:element>
                  </xsl:element>
                  <xsl:element name="required_process_ind">Y</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>

        </xsl:if>

      </xsl:for-each>
      <!-- subscription part END -->

      <!-- create a CO for all reconfigurations of async terminations and activate the CO -->
      <xsl:if test="$handleAsynchronousTermination = 'Y' and 
      				count(request-param-list[@name='configuredServiceList']/request-param-list-item) > 0">
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_reconfiguration</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="cust_order_description">TO-Umkonfiguration</xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="$OMTSOrderID"/>
            </xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
            <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
                  <xsl:element name="CcmFifCommandRefCont">
                    <xsl:element name="command_id">
                      <xsl:text>reconf_service_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                </xsl:for-each>
            </xsl:element>
            <xsl:element name="processing_status">completedOPM</xsl:element>
          </xsl:element>
        </xsl:element>
        
		<xsl:element name="CcmFifActivateCustomerOrderCmd">
			<xsl:element name="command_id">activate_co</xsl:element>
			<xsl:element name="CcmFifActivateCustomerOrderInCont">
				<xsl:element name="customer_order_id_ref">
					<xsl:element name="command_id">create_co_reconfiguration</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>

      </xsl:if>


      <!-- Add STPs to subscribe customer order if exists -->
      <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
        <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">read_customer_order</xsl:element>
            <xsl:element name="field_name">parameter_value</xsl:element>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">
                  <xsl:text>add_service_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:for-each>
            <xsl:if test="$isMovedService = 'Y' and $action != 'remove' and
              count(request-param-list[@name='configuredServiceList']/request-param-list-item) = 0">
              <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="$desiredDate = $terminationDate">
              <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">
                    <xsl:text>term_feature_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
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
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">Featureänderung</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="$OMTSOrderID"/>
          </xsl:element>
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='processingStatus'] = 'completedOPM'">
	          <xsl:element name="provider_tracking_no">
	            <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
	          </xsl:element>
	      </xsl:if>
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
            <xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">
                  <xsl:text>add_service_</xsl:text>
                  <xsl:value-of select="position()"/>
                </xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:for-each>
            <xsl:if test="$isMovedService = 'Y' and $action != 'remove' and
              count(request-param-list[@name='configuredServiceList']/request-param-list-item) = 0">
              <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">
                    <xsl:text>add_service_</xsl:text>
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="$desiredDate = $terminationDate">
              <xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">
                    <xsl:text>term_feature_</xsl:text>
                    <xsl:value-of select="position()"/>
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
            <xsl:value-of select="request-param[@name='processingStatus']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='activateCustomerOrder'] = 'Y'">
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
      </xsl:if>

      <xsl:if test="request-param[@name='processingStatus'] = ''">

        <xsl:if test="request-param[@name='workflowType'] != 'COM-OPM-FIF'">
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
        </xsl:if>

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
                  and request-param[@name='processingStatus'] = ''">
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
                      <xsl:text>term_feature_</xsl:text>
                      <xsl:value-of select="position()"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
              <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
              <xsl:element name="processing_status">
                <xsl:value-of select="request-param[@name='processingStatus']"/>
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
                <xsl:value-of select="$OMTSOrderID"/>
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
                      <xsl:text>term_feature_</xsl:text>
                      <xsl:value-of select="position()"/>
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
                <xsl:value-of select="request-param[@name='processingStatus']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:if test="request-param[@name='workflowType'] != 'COM-OPM-FIF'">          
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

	  <xsl:if test="request-param[@name='processingStatus'] = '' or
	  				request-param[@name='activateCustomerOrder'] != 'Y'">
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
	                  and request-param[@name='processingStatus'] = ''">
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
      </xsl:if>

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
                  and request-param[@name='processingStatus'] = ''">
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
      
      <!-- SPN-CCB-000132657
      		when services discounting the monthly charges are created, an additional RCP notification
      		indicating a pricing structure change is needed to trigger ERP to change the monthly charge calculation       
       -->
      <xsl:if test="request-param[@name='createRCPNotification'] = 'Y'">
        <xsl:element name="CcmFifCreateRCPNotificationCmd">
          <xsl:element name="command_id">create_rcp_notification</xsl:element>
          <xsl:element name="CcmFifCreateRCPNotificationInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
	          <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$tomorrow"/>
            </xsl:element>
            <xsl:element name="change_type_status">PSC</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="
        request-param[@name='action'] = 'remove' or
        $isMovedService = 'Y' or
        count(request-param-list[@name='configuredServiceList']/request-param-list-item) > 0">
        
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">functionStatus</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">CustomerOrderCreated</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                  <xsl:choose>
                    <xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">SUCCESS</xsl:when>
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
