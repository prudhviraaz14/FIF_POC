<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a service delivery contract
  
  @author schwarje 
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
    
    <!-- Calculate today -->
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    <!-- Calculate tomorrow -->      
    <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
    
    <xsl:element name="Command_List">
      
      <!-- Default terminationDate -->
      <xsl:variable name="terminationDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='terminationDate'] = ''">
            <xsl:value-of select="$today"/>
          </xsl:when>        
          <xsl:when test ="dateutils:compareString(request-param[@name='terminationDate'], $today) = '-1'">
            <xsl:value-of select="$today"/>
          </xsl:when>          
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>     

      <xsl:variable name="terminationDateOPM"
        select="dateutils:createOPMDate($terminationDate)"/>

      <xsl:variable name="stpDesiredDate">  
        <xsl:choose>
          <xsl:when test="request-param[@name='processingStatus'] != 'completedOPM'">
            <xsl:value-of select="$terminationDate"/>
          </xsl:when>        
        </xsl:choose>                      
      </xsl:variable>     

      <!-- Default terminationDate -->
      <xsl:variable name="scheduleType">  
        <xsl:choose>
          <xsl:when test="dateutils:compareString($terminationDate, $today) = '0'">
            <xsl:text>ASAP</xsl:text>
          </xsl:when>          
          <xsl:when test="request-param[@name='scheduleType'] = 'ASAP'">
            <xsl:text>START_AFTER</xsl:text>
          </xsl:when>        
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='scheduleType']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>     
      
      <xsl:if test="request-param[@name='documentationOnly'] = 'N'">
      
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_customer_order</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:if test="request-param[@name='isMovedService'] = 'Y'">
                <xsl:text>DUMMY_</xsl:text>
              </xsl:if>          
              <xsl:value-of select="request-param[@name='functionID']"/>
              <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>                          
        
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:if test="request-param[@name='isContractFunction'] = 'Y' and 
          request-param[@name='terminateProductSubscription'] = 'Y' and
          request-param[@name='terminateContract'] = 'Y'">
          <!-- Terminate Order Form -->
          <xsl:element name="CcmFifTerminateOrderFormCmd">
            <xsl:element name="command_id">terminate_of_1</xsl:element>
            <xsl:element name="CcmFifTerminateOrderFormInCont">
              <xsl:element name="contract_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
              <xsl:element name="termination_date">
                <xsl:value-of select="$terminationDate"/>
              </xsl:element>
              <xsl:element name="notice_per_start_date">
                <xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
              </xsl:element>
              <xsl:element name="override_restriction">Y</xsl:element>
              <xsl:element name="termination_reason_rd">
                <xsl:value-of select="request-param[@name='terminationReason']"/>
              </xsl:element>
              <xsl:element name="skip_product_subscription_validation">Y</xsl:element>
              <xsl:element name="terminated_product_subscription_id_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>            
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>          
              <xsl:element name="required_process_ind">O</xsl:element>          
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>            
            </xsl:element>
          </xsl:element>
          
          <!-- SDCPC termination -->
          <xsl:element name="CcmFifTerminateSDCProductCommitmentCmd">
            <xsl:element name="command_id">terminate_sdcpc</xsl:element>
            <xsl:element name="CcmFifTerminateSDCProductCommitmentInCont">
              <xsl:element name="product_commitment_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>
              </xsl:element>
              <xsl:element name="termination_date">
                <xsl:value-of select="$terminationDate"/>
              </xsl:element>
              <xsl:element name="notice_per_start_date">
                <xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
              </xsl:element>
              <xsl:element name="override_restriction">Y</xsl:element>
              <xsl:element name="termination_reason_rd">
                <xsl:value-of select="request-param[@name='terminationReason']"/>
              </xsl:element>
              <xsl:element name="skip_product_subscription_validation">Y</xsl:element>
              <xsl:element name="terminated_product_subscription_id_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>            
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>          
              <xsl:element name="required_process_ind">S</xsl:element>          
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
        <xsl:if test="request-param[@name='isContractFunction'] = 'Y'
          and request-param[@name='terminateProductSubscription'] = 'Y'">
          <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
            <xsl:element name="command_id">cancel_stp_1</xsl:element>
            <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="reason_rd">TERMINATION</xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- Terminate Product Subscription -->
          <xsl:element name="CcmFifTerminateProductSubsCmd">
            <xsl:element name="command_id">terminate_ps</xsl:element>
            <xsl:element name="CcmFifTerminateProductSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>   			
              <xsl:element name="desired_date">
                <xsl:value-of select="$stpDesiredDate"/>
              </xsl:element>
                <xsl:element name="desired_schedule_type">
                  <xsl:value-of select="$scheduleType"/>
                </xsl:element>
              <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reason']"/>
              </xsl:element>
              <xsl:element name="auto_customer_order">N</xsl:element>
              <xsl:element name="detailed_reason_rd">
                <xsl:value-of select="request-param[@name='detailedReason']"/>	
              </xsl:element>
              <xsl:element name="provider_tracking_no">
                <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
        <xsl:if test="request-param[@name='isContractFunction'] != 'Y' or 
          request-param[@name='terminateProductSubscription'] != 'Y'">
          <!-- Terminate serviceSubscription -->
          <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
            <xsl:element name="command_id">terminate_ps</xsl:element>
            <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
              <xsl:element name="usage_mode">4</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$stpDesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">
                <xsl:value-of select="$scheduleType"/>
              </xsl:element>
              <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reason']"/>
              </xsl:element>
              <xsl:element name="provider_tracking_no">
                <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>                        
        </xsl:if>
        
        <!-- Create and activa  early termination fee service -->
        <xsl:if test="request-param[@name='earlyTerminationFeeServiceCode'] != ''">
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_early_term_fee_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="request-param[@name='earlyTerminationFeeServiceCode']"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reason']"/>
              </xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list">
  							<!-- aktuelles Kuendigungsdatum -->
  							<xsl:element name="CcmFifConfiguredValueCont">
  								<xsl:element name="service_char_code">VI087</xsl:element>
  								<xsl:element name="data_type">DATE</xsl:element>
  								<xsl:element name="configured_value">
  									<xsl:value-of select="$terminationDateOPM"/>
  								</xsl:element>
  							</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_early_term</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">add_early_term_fee_service</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="processing_status">
                <xsl:value-of select="request-param[@name='processingStatus']"/>
              </xsl:element>              
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifActivateCustomerOrderCmd">
            <xsl:element name="command_id">activate_co</xsl:element>
            <xsl:element name="CcmFifActivateCustomerOrderInCont">
              <xsl:element name="customer_order_id_ref">
                <xsl:element name="command_id">create_co_early_term</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
          <!-- Terminate  -->
          <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
            <xsl:element name="command_id">terminate_early_term_fee_service</xsl:element>
            <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">add_early_term_fee_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="usage_mode">4</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$tomorrow"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reason']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>                        
          <!-- Create and release CO -->
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_term_early_term_fee_service_co</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">terminate_early_term_fee_service</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                </xsl:element>						
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="command_id">release_term_early_term_fee_service_co</xsl:element>
            <xsl:element name="CcmFifReleaseCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_order_ref">
                <xsl:element name="command_id">create_term_early_term_fee_service_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
        </xsl:if>
        
        <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
          <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">read_customer_order</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">terminate_ps</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>
            </xsl:element>
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
        
        <!-- Create Customer Order for Termination -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service</xsl:element>
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
                <xsl:element name="command_id">terminate_ps</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
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
                <xsl:element name="command_id">find_service</xsl:element>
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
        
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact_1</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
            <xsl:element name="short_description">Kündigung</xsl:element>
            <xsl:element name="description_text_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>Die Produktnutzung </xsl:text>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>          
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text> (Vertrag </xsl:text>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>          
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>, Serviceschein </xsl:text>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>          
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>) wurde gekündigt.</xsl:text> 
                  <xsl:if test="request-param[@name='processingStatus'] != ''">
                    <xsl:text>Die Kündigung wurde sofort aktiviert, da der </xsl:text>
                    <xsl:text>Anschluss technisch bereits abgeschaltet war.</xsl:text>
                  </xsl:if>
                  <xsl:if test="request-param[@name='activationDate'] != ''">
                    <xsl:text>&#xA;Technische Kündigung am: </xsl:text>
                    <xsl:value-of select="request-param[@name='activationDate']"/>
                  </xsl:if>
                  <xsl:text>&#xA;Kündigungsgrund: </xsl:text>
                  <xsl:value-of select="request-param[@name='terminationReason']"/>
                  <!-- TODO Auftragsart? -->
                  <xsl:text>&#xA;TransactionID: </xsl:text>
                  <xsl:value-of select="request-param[@name='transactionID']"/>
                  <xsl:text>&#xA;FIF-Client: </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
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
                  <xsl:if test="request-param[@name='isMovedService'] = 'Y'">
                    <xsl:text>MOVED_</xsl:text>
                  </xsl:if>                              
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
      </xsl:if>
      
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
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
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
