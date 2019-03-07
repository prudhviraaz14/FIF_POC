<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying access information

  @author lejam
-->
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

         <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

         <xsl:variable name="terminationDate" >
            <xsl:choose>
               <xsl:when test="request-param[@name='TERMINATION_DATE'] = '' or
                  request-param[@name='TERMINATION_DATE'] = 'today'">
                  <xsl:value-of select="$today"/>
               </xsl:when>
               <xsl:when test="dateutils:compareString(request-param[@name='TERMINATION_DATE'], $today) = '-1'">
                  <xsl:value-of select="$today"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

         <xsl:variable name="desiredDate">
            <xsl:choose>
               <xsl:when test ="request-param[@name='DESIRED_DATE'] = '' or
                  request-param[@name='DESIRED_DATE'] = 'today'">
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
               <xsl:when test ="dateutils:compareString($desiredDate, $today) = '0'">ASAP</xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

         <xsl:variable name="terminationDateAsyncGTDesiredDate" >
           <xsl:choose>          
             <xsl:when test="$terminationDate = ''">
               <xsl:text>Y</xsl:text>
             </xsl:when>          
             <xsl:when test="$terminationDate != ''
               and dateutils:compareString($terminationDate, $desiredDate) != '-1'">
               <xsl:text>Y</xsl:text>
             </xsl:when>
             <xsl:otherwise>
               <xsl:text>N</xsl:text>
             </xsl:otherwise>
           </xsl:choose>
         </xsl:variable>

         <!-- if nothing to be done log warning  -->
         <xsl:if test="$terminationDateAsyncGTDesiredDate != 'Y'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">terminate_tariff_option_async_no_task</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Keine Aufgabe, weil das Kündigungsdatum in der Vergangenheit ist.</xsl:element>
					</xsl:element>
				</xsl:element>
         </xsl:if>

         <xsl:if test="$terminationDateAsyncGTDesiredDate = 'Y'">


            <!-- Find Service Subscription by service_subscription id  -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="CcmFifFindServiceSubsInCont">
                  <xsl:element name="service_subscription_id">
                     <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                  </xsl:element>
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

            <!-- look for open STP for the respective service in state ASSIGNED or UNASSIGNED -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
               <xsl:element name="command_id">find_open_stp</xsl:element>
               <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                  <xsl:element name="service_subscription_id_ref">
	                  <xsl:element name="command_id">find_service</xsl:element>
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
               </xsl:element>
            </xsl:element>

            <!-- cancel the ASSIGNED or UNASSIGNED STP -->
            <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
               <xsl:element name="command_id">cancel_open_stp</xsl:element>
               <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
                  <xsl:element name="service_ticket_position_id_ref">
                     <xsl:element name="command_id">find_open_stp</xsl:element>
                     <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
                  </xsl:element>
                  <xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
                  <xsl:element name="process_ind_ref">
                     <xsl:element name="command_id">find_open_stp</xsl:element>
                     <xsl:element name="field_name">stp_found</xsl:element>          	
                  </xsl:element>
                  <xsl:element name="required_process_ind">Y</xsl:element>            
              </xsl:element>
            </xsl:element>              

            <!-- reconfigure service subscription -->
            <xsl:element name="CcmFifReconfigServiceCmd">
               <xsl:element name="command_id">reconfigure_service</xsl:element>
               <xsl:element name="CcmFifReconfigServiceInCont">
                  <xsl:element name="service_subscription_id">
                     <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                  </xsl:element>
                  <xsl:element name="desired_date">
                     <xsl:value-of select="$desiredDate"/>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">
                     <xsl:value-of select="$desiredScheduleType"/>
                  </xsl:element>
                  <xsl:element name="reason_rd">
                     <xsl:value-of select="request-param[@name='REASON_RD']"/>
                  </xsl:element>
                  <xsl:element name="service_characteristic_list">
                     <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0232</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">
                           <xsl:value-of select="dateutils:createOPMDate($terminationDate)"/>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="allow_stp_modification">Y</xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- create customer order  -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
               <xsl:element name="command_id">create_customer_order_1</xsl:element>
               <xsl:element name="CcmFifCreateCustOrderInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">find_service</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="customer_tracking_id">
                     <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
                  </xsl:element>
                  <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                  <xsl:element name="service_ticket_pos_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">reconfigure_service</xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                     </xsl:element>
                  </xsl:element>
                   <xsl:element name="processing_status">completedOPM</xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- release customer order -->
            <xsl:element name="CcmFifReleaseCustOrderCmd">
               <xsl:element name="command_id">release_customer_order_1</xsl:element>
               <xsl:element name="CcmFifReleaseCustOrderInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">find_service</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="customer_order_ref">
                     <xsl:element name="command_id">create_customer_order_1</xsl:element>
                     <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- Find Service Subscription by service_subscription id  -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
               <xsl:element name="command_id">find_main_service</xsl:element>
               <xsl:element name="CcmFifFindServiceSubsInCont">
                  <xsl:element name="product_subscription_id_ref">
                     <xsl:element name="command_id">find_service</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
               </xsl:element>
            </xsl:element>


            <xsl:element name="CcmFifCreateContactCmd">
               <xsl:element name="CcmFifCreateContactInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">find_service</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
                  <xsl:element name="short_description">Kündigungsdatum gesetzt</xsl:element>
                  <xsl:element name="description_text_list">
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="contact_text">
                           <xsl:text>Kündigungsdatum </xsl:text> 
                           <xsl:value-of select="dateutils:createOPMDate($terminationDate)"/>
                           <xsl:text> gesetzt für Tarifoption </xsl:text> 
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_service</xsl:element>
                        <xsl:element name="field_name">service_code</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="contact_text">
                           <xsl:text> von Hauptdienst </xsl:text>
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_main_service</xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="contact_text">
                           <xsl:text>&#xA;TransactionID: </xsl:text>
                           <xsl:value-of select="request-param[@name='transactionID']"/>
                           <xsl:text> (</xsl:text>
                           <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
                           <xsl:text>)</xsl:text>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            
            <!-- create asynchronous termination fif request -->
            <xsl:element name="CcmFifCreateFifRequestCmd">
                  <xsl:element name="command_id">
                    <xsl:text>create_fif_request_tTO</xsl:text>
                  </xsl:element>
              <xsl:element name="CcmFifCreateFifRequestInCont">
                <xsl:element name="action_name">terminateTariffOption</xsl:element>
                <xsl:element name="due_date">
                  <xsl:value-of select="$terminationDate"/>
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
                      <xsl:element name="command_id">find_service</xsl:element>
                      <xsl:element name="field_name">customer_number</xsl:element>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                    <xsl:element name="parameter_value_ref">
                      <xsl:element name="command_id">find_service</xsl:element>
                      <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">serviceCode</xsl:element>
                    <xsl:element name="parameter_value_ref">
                      <xsl:element name="command_id">find_service</xsl:element>
                      <xsl:element name="field_name">service_code</xsl:element>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">terminationDate</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$terminationDate"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">handleContributingItem</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='HANDLE_CONTRIBUTING_ITEM']"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">OMTSOrderID</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">reason</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='REASON_RD']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>

          </xsl:if>

         
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
