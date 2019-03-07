<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated termination FIF request

  @author goethalo
-->

<!DOCTYPE XSL [

<!ENTITY TerminateService_BitDSL SYSTEM "TerminateService_BitDSL.xsl">
<!ENTITY TerminateService_BitVoIP SYSTEM "TerminateService_BitVoIP.xsl">
<!ENTITY TerminateService_NgnDSL SYSTEM "TerminateService_NGNDSL.xsl">
<!ENTITY TerminateService_NgnVoIP SYSTEM "TerminateService_NGNVoIP.xsl">
<!ENTITY TerminateServ_VoIP SYSTEM "TerminateService_VoIP.xsl">
<!ENTITY TerminateServ_DSLR SYSTEM "TerminateService_DSLResale.xsl">
<!ENTITY TerminateServ_Call SYSTEM "TerminateService_Call.xsl">
<!ENTITY TerminateServ_Def SYSTEM "TerminateService_Default.xsl">
<!ENTITY TerminateServ_Preselect SYSTEM "TerminateService_Preselect.xsl">
<!ENTITY TerminateService_Multimedia SYSTEM "TerminateService_Multimedia.xsl">
<!ENTITY TerminateService_Online SYSTEM "TerminateService_Online.xsl">
<!ENTITY TerminateService_Mobile SYSTEM "KBATerminateService_Mobile.xsl">
<!ENTITY TerminateService_PCBackup SYSTEM "TerminateService_PCBackup.xsl">
<!ENTITY TerminateService_MOS SYSTEM "TerminateService_MOS.xsl">
<!ENTITY TerminateService_SDSL SYSTEM "TerminateService_SDSL.xsl">
<!ENTITY TerminateService_TVCenter SYSTEM "TerminateService_TVCenter.xsl">
<!ENTITY TerminateService_TVCenterStandAlone SYSTEM "TerminateService_TVCenterStandAlone.xsl">
<!ENTITY HandleMMAccessHardware SYSTEM "HandleMMAccessHardware.xsl">
]>
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

    <xsl:variable name="terminationBarcode">
      <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
    </xsl:variable>
    
    <xsl:variable name="scenarioType"/>
    
    <!--
       SIMPLE TERMINATION
      -->

    <xsl:if test="request-param[@name='terminationType'] = 'Simple'">
     
      <xsl:element name="Command_List">
        
        <!-- Ensure that the termination type is set correctly -->
        <xsl:if test=" request-param[@name='productCode'] = 'I1201' or
          request-param[@name='productCode'] = 'VI001' or
          request-param[@name='productCode'] = 'VI201' or
          request-param[@name='productCode'] = 'I1204' or 
          request-param[@name='productCode'] = 'VI202' or
          request-param[@name='productCode'] = 'I1302' or
          request-param[@name='productCode'] = 'I1304' or
          request-param[@name='productCode'] = 'I1203' or
          request-param[@name='productCode'] = 'VI203' or
          request-param[@name='productCode'] = 'V8000' or
          request-param[@name='productCode'] = 'I4000' or
          request-param[@name='productCode'] = 'I4001' or
          request-param[@name='productCode'] = 'I1207' or  
          request-param[@name='productCode'] = 'I1305' or 
          request-param[@name='productCode'] = 'I1306' or         
          (request-param[@name='productCode'] = 'V0001' and
            request-param[@name='upgradeToVoIPIndicator'] = 'Y')">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">error_1</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">This product can not be terminated as a SIMPLE TERMINATION!</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if> 

		<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:if test="request-param[@name='productCode'] = 'V0001'">
            <!-- Terminate Product Subscription -->
	    	<xsl:element name="CcmFifTerminateProductSubsCmd">
	    		<xsl:element name="command_id">terminate_ps_1</xsl:element>
	    		<xsl:element name="CcmFifTerminateProductSubsInCont">
	    			<xsl:element name="product_subscription_ref">
	    				<xsl:element name="command_id">find_main_service</xsl:element>
	    				<xsl:element name="field_name">product_subscription_id</xsl:element>
	    			</xsl:element>   			
	    			<xsl:element name="desired_date">
	    				<xsl:value-of select="request-param[@name='terminationDate']"/>
	    			</xsl:element>
	    			<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
	    			<xsl:element name="reason_rd">TERMINATION</xsl:element>	      
	    			<xsl:element name="auto_customer_order">N</xsl:element>         
	    		</xsl:element>
	    	</xsl:element>
	    	
	    	<!-- Create Customer Order for Termination -->
	    	<xsl:element name="CcmFifCreateCustOrderCmd">
	    		<xsl:element name="command_id">create_co_1</xsl:element>
	    		<xsl:element name="CcmFifCreateCustOrderInCont">
	    			<xsl:element name="customer_number_ref">
	    				<xsl:element name="command_id">find_main_service</xsl:element>
	    				<xsl:element name="field_name">customer_number</xsl:element>
	    			</xsl:element>
	    			<xsl:element name="customer_tracking_id">
	    				<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
	    			</xsl:element>	
	    			<xsl:element name="provider_tracking_no">
	    				<xsl:choose>
	    					<xsl:when test="request-param[@name='providerTrackingNumberDefault'] != ''">
	    						<xsl:value-of select="request-param[@name='providerTrackingNumberDefault']" />
	    					</xsl:when>
	    					<xsl:otherwise>002</xsl:otherwise>
	    				</xsl:choose>
	    			</xsl:element>
	    			<xsl:element name="service_ticket_pos_list">
	    				<xsl:element name="CcmFifCommandRefCont">
	    					<xsl:element name="command_id">terminate_ps_1</xsl:element>
	    					<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
	    				</xsl:element>
	    			</xsl:element>
	    		</xsl:element>
	    	</xsl:element>
	    	
	    	<!-- Release Customer Order for Termination -->
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
	    		</xsl:element>
	    	</xsl:element>
          
          </xsl:if>
          
          
		</xsl:if>
          
        <!-- Add Termination Fee Service -->
        <xsl:if test="request-param[@name='terminationFeeServiceCode'] != '' and
          request-param[@name='serviceSubscriptionId'] != ''">
          
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_fee_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="request-param[@name='terminationFeeServiceCode']"/>
              </xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              <xsl:element name="reason_rd">TERMINATION</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
        <xsl:if test="request-param[@name='terminationFeeServiceCode'] != '' and
          request-param[@name='serviceSubscriptionId'] != '' and 
          request-param[@name='productCode'] != 'I1100'">        
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_fee_co</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="$terminationBarcode"/>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">add_fee_service</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- Release Customer Order  -->
          <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="CcmFifReleaseCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_order_ref">
                <xsl:element name="command_id">create_fee_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>                              
        </xsl:if>       
        
        <!-- Terminate Order Form -->
        <xsl:element name="CcmFifTerminateOrderFormCmd">
          <xsl:element name="command_id">terminate_of_1</xsl:element>
          <xsl:element name="CcmFifTerminateOrderFormInCont">
            <xsl:element name="contract_number">
              <xsl:value-of select="request-param[@name='contractNumber']"/>
            </xsl:element>
            <xsl:element name="termination_date">
              <xsl:choose>
                <xsl:when test="request-param[@name='clientName'] = 'SLS' and
                  dateutils:compareString(dateutils:getCurrentDate(), request-param[@name='terminationDate']) = '1'">
                  <xsl:value-of select="dateutils:getCurrentDate()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="request-param[@name='terminationDate']"/>
                </xsl:otherwise>
              </xsl:choose>          
            </xsl:element>
            <xsl:element name="notice_per_start_date">
              <xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
            </xsl:element>
            <xsl:element name="override_restriction">Y</xsl:element>
            <xsl:element name="termination_reason_rd">
              <xsl:value-of select="request-param[@name='terminationReason']"/>
            </xsl:element>
            <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>          
              <xsl:element name="required_process_ind">O</xsl:element>            	
            </xsl:if>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>            
          </xsl:element>
        </xsl:element>

        <xsl:if test="request-param[@name='productCode'] = 'I1100'"> 
          &TerminateService_Online;
        </xsl:if>  
                
        <!-- Create Contact for the Service Termination -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
            <xsl:element name="short_description">Automatische Kündigung</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;ContractNumber: </xsl:text>
              <xsl:value-of select="request-param[@name='contractNumber']"/>
              <xsl:text>&#xA;TerminationReason: </xsl:text>
              <xsl:value-of select="request-param[@name='terminationReason']"/>
              <xsl:text>&#xA;DeactivateOnlineAccount: </xsl:text>
              <xsl:value-of select="request-param[@name='deactivateOnlineAccount']"/>
              <xsl:text>&#xA;SendConfirmationLetter: </xsl:text>
              <xsl:value-of select="request-param[@name='sendConfirmationLetter']"/>
              <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
              <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>       
        <xsl:if test="request-param[@name='clientName'] = 'CODB'">
          <xsl:element name="CcmFifPassBackValueCmd">
            <xsl:element name="command_id">passback_1</xsl:element>
            <xsl:element name="CcmFifPassBackValueInCont">
              <xsl:element name="parameter_value_list">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">orderId</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='orderId']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
            <xsl:element name="CcmFifPassBackValueCmd">
              <xsl:element name="command_id">passback_2</xsl:element>
              <xsl:element name="CcmFifPassBackValueInCont">
                <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] != ''">
            <xsl:element name="CcmFifGetEntityCmd">
              <xsl:element name="command_id">get_entity_1</xsl:element>
              <xsl:element name="CcmFifGetEntityInCont">
                <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifGetCustomerDataCmd">
              <xsl:element name="command_id">get_customer_data</xsl:element>
              <xsl:element name="CcmFifGetCustomerDataInCont">
                <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifGetContactRoleDataCmd">
              <xsl:element name="command_id">get_contact_role_data</xsl:element>
              <xsl:element name="CcmFifGetContactRoleDataInCont">
                <xsl:element name="supported_object_id">
                  <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
                <xsl:element name="supported_object_type_rd">CUSTOMER</xsl:element>          
                <xsl:element name="contact_role_type_rd">INHABER</xsl:element>          
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifGetAddressDataCmd">
              <xsl:element name="command_id">get_address_data</xsl:element>
              <xsl:element name="CcmFifGetAddressDataInCont">
                <xsl:element name="address_id_ref">
                  <xsl:element name="command_id">get_entity_1</xsl:element>
                  <xsl:element name="field_name">primary_address_id</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>  
          </xsl:if>      
        </xsl:if>
      </xsl:element>
    </xsl:if>

    <!--
       COMPLEX TERMINATION
      -->

    <xsl:if test="request-param[@name='terminationType'] = 'Complex'">
      <xsl:element name="Command_List">
        
        <!-- Calculate today and one day before the desired date -->
        <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
        
        <!-- Generate a FIF date that is one day before the termination date -->
        <xsl:variable name="oneDayBefore"
          select="dateutils:createFIFDateOffset(request-param[@name='terminationDate'], 'DATE', '-1')"/>
        <!-- Convert the termination date to OPM format -->
        <xsl:variable name="terminationDateOPM"
          select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
        
        <xsl:variable name="TerminationDate">
          <xsl:value-of select="request-param[@name='terminationDate']"/>
        </xsl:variable> 

        <xsl:variable name="OrderVariant">
          <xsl:value-of select="request-param[@name='orderVariant']"/>
        </xsl:variable>
        <xsl:variable name="VoIPTermOrderVariant">Vorbereitung zur Kuendigung</xsl:variable>        
        
        <xsl:variable name="ReasonRd">TERMINATION</xsl:variable> 
  
        <xsl:variable name="NoticePeriodStartDate">
          <xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
        </xsl:variable>          
 
        <xsl:variable name="TerminationReason">
          <xsl:value-of select="request-param[@name='terminationReason']"/>
        </xsl:variable>

       <xsl:if test="request-param[@name='productCode'] = ''">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">error_1</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">No product code provided for complex termination</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>

        <!-- Ensure that the termination type is set correctly -->
        <xsl:if test="request-param[@name='productCode'] = 'V0001' and
          request-param[@name='upgradeToVoIPIndicator'] != 'Y'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">error_2</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Preselection (V0001) can be terminated as a COMPLEX TERMINATION only if the parameter upgradeToVoIPIndicator is set to 'Y'!!</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if> 
        
        
            
            <!-- find directory entry stp -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_directory_entry</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="contract_number">
                  <xsl:value-of select="request-param[@name='contractNumber']"/>            
                </xsl:element>
                <xsl:element name="no_stp_error">N</xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0100</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="customer_order_state">RELEASED</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- get data from STP -->
            <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
              <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
              <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
                <xsl:element name="service_ticket_position_id_ref">
                  <xsl:element name="command_id">find_directory_entry</xsl:element>
                  <xsl:element name="field_name">service_ticket_position_id</xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_directory_entry</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- cancel the service in OPM -->
            <xsl:element name="CcmFifCancelCustomerOrderCmd">
              <xsl:element name="command_id">cancel_directory_entry</xsl:element>
              <xsl:element name="CcmFifCancelCustomerOrderInCont">
                <xsl:element name="customer_order_id_ref">
                  <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>            
                </xsl:element>
                <xsl:element name="cancel_reason_rd">UMZ</xsl:element>
                <xsl:element name="cancel_opm_order_ind">Y</xsl:element>
                <xsl:element name="skip_already_processed">Y</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_directory_entry</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>          
                <xsl:element name="required_process_ind">Y</xsl:element>
              </xsl:element>
            </xsl:element>
            
			  <!-- do not raise an error if no relased STP found or if OPM order does not exists but OP internal order has been successfully rejected -->      
			  <xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">map_raise_error</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
				  <xsl:element name="input_string_type">[Y,N]_[Y,N,]</xsl:element>
					<xsl:element name="input_string_list">
					  <xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">find_directory_entry</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					  </xsl:element>
					  <xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">_</xsl:element>							
					  </xsl:element>
					  <xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">cancel_directory_entry</xsl:element>
						<xsl:element name="field_name">op_order_rejected_ind</xsl:element>							
					  </xsl:element>
					</xsl:element>
				  <xsl:element name="output_string_type">[Y,N]</xsl:element>
				  <xsl:element name="string_mapping_list">
					<xsl:element name="CcmFifStringMappingCont">
					  <xsl:element name="input_string">Y_N</xsl:element>
					  <xsl:element name="output_string">Y</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifStringMappingCont">
					  <xsl:element name="input_string">Y_</xsl:element>
					  <xsl:element name="output_string">Y</xsl:element>
					</xsl:element>
				  </xsl:element>
				  <xsl:element name="no_mapping_error">N</xsl:element>
				</xsl:element>
			  </xsl:element>
		
			  <!-- raise error to initiate functional recycling -->      
			  <xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">raise_error_func_recycle</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
				  <xsl:element name="error_text">IT-22324: TBE-Stornierung in Arbeit, Request muss morgen wieder ausgeführt werden.</xsl:element>
				  <xsl:element name="ccm_error_code">146131</xsl:element>
				  <xsl:element name="process_ind_ref">
					<xsl:element name="command_id">map_raise_error</xsl:element>
					<xsl:element name="field_name">output_string</xsl:element>							
				  </xsl:element>          
				  <xsl:element name="required_process_ind">Y</xsl:element>          
				</xsl:element>
			  </xsl:element>     

              
        <xsl:if test="request-param[@name='productCode'] != 'I1201' and
                     request-param[@name='productCode'] != 'VI001' and
                     request-param[@name='productCode'] != 'VI201' and
                     request-param[@name='productCode'] != 'I1204' and 
                     request-param[@name='productCode'] != 'VI202' and
                     request-param[@name='productCode'] != 'V0001' and
                     request-param[@name='productCode'] != 'I1302' and
                     request-param[@name='productCode'] != 'I1203' and
                     request-param[@name='productCode'] != 'VI203' and
                     request-param[@name='productCode'] != 'I1304' and
                     request-param[@name='productCode'] != 'I4000' and
                     request-param[@name='productCode'] != 'I4001' and
                     request-param[@name='productCode'] != 'I1207' and
                     request-param[@name='productCode'] != 'V8000' and
                     request-param[@name='productCode'] != 'I1305'  and
                     request-param[@name='productCode'] != 'I1306' ">
            <!--
                TERMINATION OF NORMAL ARCOR PRODUCT
            -->
            &TerminateServ_Def;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'I1201'">
            <!--
                TERMINATION OF T-DSL RESALE PRODUCT
            -->
            &TerminateServ_DSLR;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'VI001'">
            <!--
                TERMINATION OF CALL 
            -->
            &TerminateServ_Call;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'VI201'">              
            <!--
                 TERMINATION OF VoIP PRODUCT
            -->
                &TerminateServ_VoIP;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'VI202'">
            <!--
                 TERMINATION OF NGN VoIP PRODUCT
            -->
                &TerminateService_NgnVoIP;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'I1204'">
            <!--
                  TERMINATION OF NGN DSL PRODUCT
            -->
            &TerminateService_NgnDSL;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'V0001'
          and request-param[@name='upgradeToVoIPIndicator'] = 'Y'">              
            <!--
               TERMINATION OF Preselect PRODUCT
            -->
          &TerminateServ_Preselect;
        </xsl:if>
        
        <xsl:if test="request-param[@name='productCode'] = 'I1302' or
          request-param[@name='productCode'] = 'I1304'">
            <!--
               TERMINATION OF NGN DSL PRODUCT
            -->
          &TerminateService_Multimedia;
        </xsl:if>    
        
        <xsl:if test="request-param[@name='productCode'] = 'I1203'">
            <!--
             TERMINATION OF Bit DSL PRODUCT
            -->
          &TerminateService_BitDSL;
        </xsl:if>
        
        <xsl:if test="request-param[@name='productCode'] = 'VI203'">
            <!--
             TERMINATION OF Bit VoIP PRODUCT
            -->
            &TerminateService_BitVoIP;
        </xsl:if>
        
        <xsl:if test="request-param[@name='productCode'] = 'V8000'">
          <!--
            TERMINATION OF A MOBILE PRODUCT
          -->
          &TerminateService_Mobile;
        </xsl:if>
        
        <xsl:if test="request-param[@name='productCode'] = 'I4000'">
          <!--
            TERMINATION OF PC Backup
          -->
          &TerminateService_PCBackup;
        </xsl:if>
        
        <xsl:if test="request-param[@name='productCode'] = 'I4001'">
          <!--
            TERMINATION OF MOS
          -->
          &TerminateService_MOS;
        </xsl:if>
        
        <xsl:if test="request-param[@name='productCode'] = 'I1207'">
          <!--
            TERMINATION OF MOS
          -->
          &TerminateService_SDSL;
        </xsl:if>
        <!--
          TERMINATION OF TV Center
        -->
        <xsl:if test="request-param[@name='productCode'] = 'I1305'">
          <!--
            TERMINATION OF NGN DSL PRODUCT
          -->
          &TerminateService_TVCenter;
        </xsl:if>
        <xsl:if test="request-param[@name='productCode'] = 'I1306'">
          <!--
            TERMINATION OF NGN DSL PRODUCT
          -->
          &TerminateService_TVCenterStandAlone;
        </xsl:if> 
        
          <xsl:if test="request-param[@name='clientName'] = 'CODB'">
            <xsl:element name="CcmFifPassBackValueCmd">
              <xsl:element name="command_id">passback_1</xsl:element>
              <xsl:element name="CcmFifPassBackValueInCont">
                <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">orderId</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='orderId']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassBackValueCmd">
              <xsl:element name="command_id">passback_2</xsl:element>
              <xsl:element name="CcmFifPassBackValueInCont">
                <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
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
              <xsl:element name="command_id">functionStatus</xsl:element>
              <xsl:element name="CcmFifConcatStringsInCont">
                <xsl:element name="input_string_list">
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="value">ACKNOWLEDGED</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>			
            
            <xsl:if test="request-param[@name='customerNumber'] != ''">
              <xsl:element name="CcmFifGetEntityCmd">
                <xsl:element name="command_id">get_entity_1</xsl:element>
                <xsl:element name="CcmFifGetEntityInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifGetCustomerDataCmd">
                <xsl:element name="command_id">get_customer_data</xsl:element>
                <xsl:element name="CcmFifGetCustomerDataInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifGetContactRoleDataCmd">
                <xsl:element name="command_id">get_contact_role_data</xsl:element>
                <xsl:element name="CcmFifGetContactRoleDataInCont">
                  <xsl:element name="supported_object_id">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="supported_object_type_rd">CUSTOMER</xsl:element>          
                  <xsl:element name="contact_role_type_rd">INHABER</xsl:element>          
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifGetAddressDataCmd">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="CcmFifGetAddressDataInCont">
                  <xsl:element name="address_id_ref">
                    <xsl:element name="command_id">get_entity_1</xsl:element>
                    <xsl:element name="field_name">primary_address_id</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>        
          </xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
