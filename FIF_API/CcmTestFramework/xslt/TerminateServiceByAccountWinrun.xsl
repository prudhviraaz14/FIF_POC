<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations
  
  @author schwarje
-->
<xsl:stylesheet version="1.0"
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

    <xsl:variable name="TerminationReason">
      <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
    </xsl:variable>

    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

	 <xsl:variable name="TerminationDateMin"
		 select="dateutils:createFIFDateOffset($today, 'DATE', '5')"/>

	 <xsl:variable name="TerminationDate"
		 select="request-param[@name='TERMINATION_DATE']"/>
		 
		 <!-- Adding new parameter ProjectOrder -->
	<xsl:variable name="ProjectOrder">
	    <xsl:value-of select="request-param[@name='PROJECT_ORDER']"/>
    </xsl:variable>
	
		<!--  Adding new parameter SupressConfirmationLetter  -->
	<xsl:variable name="SupressConfirmationLetter">
	    <xsl:value-of select="request-param[@name='SUPRESS_CONFIRMATION_LETTER']"/>
    </xsl:variable>
	
    

    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <!-- map KBACategory -->
    <xsl:variable name="KBACategory">
	   <xsl:choose>
		   <xsl:when test="request-param[@name='KBA_CATEGORY'] = ''">				
		     <xsl:choose>
			     <xsl:when test="$TerminationReason = 'AGKM'
                              or $TerminationReason = 'AGKB'
                              or $TerminationReason = 'AGKI'">
                <xsl:text>TerminationErrorFIFDunning</xsl:text>
              </xsl:when>                
			     <xsl:otherwise>
                <xsl:text>TerminationErrorFIF</xsl:text>
			     </xsl:otherwise>				
		     </xsl:choose>
         </xsl:when>                
		   <xsl:otherwise>
			   <xsl:value-of select="request-param[@name='KBA_CATEGORY']"/>
		   </xsl:otherwise>				
	   </xsl:choose>
    </xsl:variable>

    <xsl:element name="Command_List">
	    <xsl:choose>
         <!-- incorrect intput parameters -->
         <xsl:when test="request-param[@name='ACCOUNT_NUMBER'] = '' and request-param[@name='SERVICE_SUBSCRIPTION_ID'] = ''">

           <xsl:element name="CcmFifRaiseErrorCmd">
             <xsl:element name="command_id">missing_search_parameter_error</xsl:element>
             <xsl:element name="CcmFifRaiseErrorInCont">
               <xsl:element name="error_text">
                 <xsl:text>Eine von diesen Parametern (ACCOUNT_NUMBER, SERVICE_SUBSCRIPTION_ID) muß eingegeben werden!</xsl:text>
               </xsl:element>
             </xsl:element>
           </xsl:element>

         </xsl:when>

         <xsl:when test="request-param[@name='ACCOUNT_NUMBER'] != '' and request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">

           <xsl:element name="CcmFifRaiseErrorCmd">
             <xsl:element name="command_id">missing_search_parameter_error</xsl:element>
             <xsl:element name="CcmFifRaiseErrorInCont">
               <xsl:element name="error_text">
                 <xsl:text>Nur eine von diesen Parametern (ACCOUNT_NUMBER, SERVICE_SUBSCRIPTION_ID) kann eingegeben werden!</xsl:text>
               </xsl:element>
             </xsl:element>
           </xsl:element>

         </xsl:when>

         <xsl:when test="request-param[@name='ACCOUNT_NUMBER'] != ''">

         <!-- get account data -->
         <xsl:element name="CcmFifGetAccountDataCmd">
           <xsl:element name="command_id">get_account_data</xsl:element>
           <xsl:element name="CcmFifGetAccountDataInCont">
             <xsl:element name="account_number">
               <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
             </xsl:element>
             <xsl:element name="effective_date">
               <xsl:value-of select="$today"/>
             </xsl:element>
           </xsl:element>
         </xsl:element>

	    </xsl:when>
	    <xsl:otherwise>

	      <!-- get Service Subscription ID -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="$today"/>
              </xsl:element>
            </xsl:element>    
          </xsl:element>

	   </xsl:otherwise>
     </xsl:choose>

	  
	  
      <!-- incorrect termination date format -->
      <xsl:if test="dateutils:matchPattern('((19|20)[0-9]{2}).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])[ ]([0-5][0-9]):([0-5][0-9]):([0-5][0-9])', $TerminationDate) = 'N'">

        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">incorrect_termination_date_format_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              <xsl:text>Das Kündigungsdatum (</xsl:text>
              <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
              <xsl:text>) hat ein ungültiges Datumformat.</xsl:text>
            </xsl:element>
          </xsl:element>
        </xsl:element>

      </xsl:if>
      <!-- incorrect termination date format -->


      <!-- TerminationDate < terminationDateMin-->
      <xsl:if test="dateutils:compareString($TerminationDate, $TerminationDateMin) = '-1'
                    and not (dateutils:matchPattern('((19|20)[0-9]{2}).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])[ ]([0-5][0-9]):([0-5][0-9]):([0-5][0-9])', $TerminationDate) = 'N')">

        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">incorrect_termination_date_format_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              <xsl:text>Das Kündigungsdatum (</xsl:text>
              <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
              <xsl:text>) muss mindestens 5 Tagen in der Zukunft liegen.</xsl:text>
            </xsl:element>
            <!--<xsl:element name="log_warning">Y</xsl:element>-->
          </xsl:element>
        </xsl:element>

      </xsl:if>
      <!-- TerminationDate < terminationDateMin-->

      <!-- after errors above no sense to process anything else -->
      <xsl:if test="not (dateutils:matchPattern('((19|20)[0-9]{2}).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])[ ]([0-5][0-9]):([0-5][0-9]):([0-5][0-9])', $TerminationDate) = 'N')
                     and not (dateutils:compareString($TerminationDate, $TerminationDateMin) = '-1')">

      <xsl:element name="CcmFifGetCustomerDataCmd">
        <xsl:element name="command_id">get_customer_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerDataInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element> 
      
	  <!-- Find open external orders -->
     <xsl:choose>
		 <xsl:when test="request-param[@name='ACCOUNT_NUMBER']! = ''">
       <xsl:element name="CcmFifFindExternalOrderCmd">
         <xsl:element name="command_id">find_external_order</xsl:element>
         <xsl:element name="CcmFifFindExternalOrderInCont">
           <xsl:element name="customer_number_ref">
             <xsl:element name="command_id">get_account_data</xsl:element>
             <xsl:element name="field_name">customer_number</xsl:element>
           </xsl:element>
         </xsl:element>
       </xsl:element> 
	    </xsl:when>
	  
	    <xsl:otherwise>
	    <xsl:element name="CcmFifFindExternalOrderCmd">
            <xsl:element name="command_id">find_external_order</xsl:element>
            <xsl:element name="CcmFifFindExternalOrderInCont">
              <xsl:element name="product_subscription_id_ref">
                <xsl:element name="command_id">get_account_data</xsl:element>			
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
       </xsl:otherwise>	    
	  </xsl:choose>
	  

      <!-- Create KBA notification  -->
		<xsl:element name="CcmFifConcatStringsCmd">
			<xsl:element name="command_id">concat_external_order</xsl:element>
			<xsl:element name="CcmFifConcatStringsInCont">
				<xsl:element name="input_string_list">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">
                     <xsl:text>Der Kunde hat die folgenden offenen externen Aufträge (</xsl:text>
                  </xsl:element>							
					</xsl:element>
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">find_external_order</xsl:element>
						<xsl:element name="field_name">order_id</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">
                     <xsl:text>). Die Kündigung kann nicht dürchgeführt werden.</xsl:text>
                  </xsl:element>							
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>

      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">open_external_order_found_error</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text_ref">
            <xsl:element name="command_id">concat_external_order</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_external_order</xsl:element>
            <xsl:element name="field_name">external_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find open customer orders -->
	  <!-- Find open external orders -->
     <xsl:choose>
		 <xsl:when test="request-param[@name='ACCOUNT_NUMBER']! = ''">

         <xsl:element name="CcmFifFindServiceTicketPositionCmd">
           <xsl:element name="command_id">find_open_stp</xsl:element>
           <xsl:element name="CcmFifFindServiceTicketPositionInCont">
             <xsl:element name="customer_number_ref">
               <xsl:element name="command_id">get_account_data</xsl:element>
               <xsl:element name="field_name">customer_number</xsl:element>
             </xsl:element>
             <xsl:element name="no_stp_error">N</xsl:element>
             <xsl:element name="find_stp_parameters">
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">DEFINED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">RELEASED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">COMPLETED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">REJECTED</xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:element>
         </xsl:element>

	    </xsl:when>
	    <xsl:otherwise>

         <xsl:element name="CcmFifFindBundleCmd">
           <xsl:element name="command_id">find_bundle</xsl:element>
           <xsl:element name="CcmFifFindBundleInCont">
             <xsl:element name="supported_object_id">
               <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
             </xsl:element>
             <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
             <xsl:element name="bundle_role_default_only">Y</xsl:element>
           </xsl:element>
         </xsl:element>

         <xsl:element name="CcmFifFindServiceTicketPositionCmd">
           <xsl:element name="command_id">find_open_stp</xsl:element>
           <xsl:element name="CcmFifFindServiceTicketPositionInCont">
             <xsl:element name="product_subscription_id_ref">
               <xsl:element name="command_id">get_account_data</xsl:element>
               <xsl:element name="field_name">product_subscription_id</xsl:element>
             </xsl:element>
             <xsl:element name="no_stp_error">N</xsl:element>
             <xsl:element name="find_stp_parameters">
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">DEFINED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">RELEASED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">COMPLETED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">REJECTED</xsl:element>
               </xsl:element>
             </xsl:element>
             <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">find_bundle</xsl:element>
               <xsl:element name="field_name">bundle_found</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">N</xsl:element>   
           </xsl:element>
         </xsl:element>

         <xsl:element name="CcmFifFindServiceTicketPositionCmd">
           <xsl:element name="command_id">find_open_stp</xsl:element>
           <xsl:element name="CcmFifFindServiceTicketPositionInCont">
             <xsl:element name="no_stp_error">N</xsl:element>
             <xsl:element name="bundle_id_ref">
               <xsl:element name="command_id">find_bundle</xsl:element>
               <xsl:element name="field_name">bundle_id</xsl:element>
             </xsl:element>
             <xsl:element name="bundle_include_other_services">Y</xsl:element>
             <xsl:element name="find_stp_parameters">
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">DEFINED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">RELEASED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">COMPLETED</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifFindStpParameterCont">
                 <xsl:element name="customer_order_state">REJECTED</xsl:element>
               </xsl:element>
             </xsl:element>
             <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">find_bundle</xsl:element>
               <xsl:element name="field_name">bundle_found</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">Y</xsl:element>   
           </xsl:element>
         </xsl:element>

        </xsl:otherwise>	    
 	  </xsl:choose>


      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_open_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_open_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_open_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>   
        </xsl:element>
      </xsl:element>

      <!-- Create KBA notification  -->
		<xsl:element name="CcmFifConcatStringsCmd">
			<xsl:element name="command_id">concat_customer_order</xsl:element>
			<xsl:element name="CcmFifConcatStringsInCont">
				<xsl:element name="input_string_list">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">
                     <xsl:text>Der Kunde hat die folgenden offenen internen Aufträge (</xsl:text>
                  </xsl:element>							
					</xsl:element>
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">get_open_stp_data</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">
                     <xsl:text>). Die Kündigung kann nicht dürchgeführt werden.</xsl:text>
                  </xsl:element>							
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>

      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">open_customer_order_found_error</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text_ref">
            <xsl:element name="command_id">concat_customer_order</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_open_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">open_order_found</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">[Y,N]_[Y,N,]</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_external_order</xsl:element>
                <xsl:element name="field_name">external_order_found</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">_</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_open_stp</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>							
              </xsl:element>
            </xsl:element>
          <xsl:element name="output_string_type">[Y,N]</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">N_N</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find main access Services -->
	  
	   <xsl:choose>
        <xsl:when test="request-param[@name='ACCOUNT_NUMBER'] != ''">
       <xsl:element name="CcmFifGetMainAccessServicesForAccountCmd">
         <xsl:element name="command_id">get_main_access_services_1</xsl:element>
         <xsl:element name="CcmFifGetMainAccessServicesForAccountInCont">
           <xsl:element name="account_number">
             <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
           </xsl:element>
           <xsl:element name="effective_date">
             <xsl:value-of select="$TerminationDate"/>
           </xsl:element>                
           <xsl:element name="process_ind_ref">
             <xsl:element name="command_id">open_order_found</xsl:element>
             <xsl:element name="field_name">output_string</xsl:element>							
           </xsl:element>          
           <xsl:element name="required_process_ind">N</xsl:element>          
         </xsl:element>
       </xsl:element>
	   </xsl:when>


	   <xsl:otherwise>
	   <!-- Find Bundle ID using Service Subscription ID -->
	   <xsl:element name="CcmFifFindBundleCmd">
           <xsl:element name="command_id">find_bundle_1</xsl:element>
           <xsl:element name="CcmFifFindBundleInCont">
             <xsl:element name="supported_object_id">
				 <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
             </xsl:element>
             <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
             <xsl:element name="bundle_role_default_only">Y</xsl:element>
           <xsl:element name="process_ind_ref">
             <xsl:element name="command_id">open_order_found</xsl:element>
             <xsl:element name="field_name">output_string</xsl:element>							
           </xsl:element>          
           <xsl:element name="required_process_ind">N</xsl:element>          
           </xsl:element>
         </xsl:element>

	   <!-- Find main access service using Bundle ID -->
	   <xsl:element name="CcmFifGetServiceSubsForBundleCmd">
         <xsl:element name="command_id">get_main_access_services_1</xsl:element>
         <xsl:element name="CcmFifGetServiceSubsForBundleInCont">
   		  <xsl:element name="bundle_id_ref">
               <xsl:element name="command_id">find_bundle_1</xsl:element>
               <xsl:element name="field_name">bundle_id</xsl:element>
           </xsl:element>
           <xsl:element name="service_type">MAIN_ACCESS</xsl:element>
           <xsl:element name="process_ind_ref">
             <xsl:element name="command_id">open_order_found</xsl:element>
             <xsl:element name="field_name">output_string</xsl:element>							
           </xsl:element>          
           <xsl:element name="required_process_ind">N</xsl:element>          
         </xsl:element>
       </xsl:element>
	  </xsl:otherwise>
    </xsl:choose>

      
      <!-- Terminate simple services & cancels ordered ones -->
      <xsl:element name="CcmFifTerminateServicesSOMCmd">
        <xsl:element name="command_id">term_simple_services_1</xsl:element>
        <xsl:element name="CcmFifTerminateServicesSOMInCont">
          <xsl:element name="service_subscription_list_ref">
            <xsl:element name="command_id">get_main_access_services_1</xsl:element>
            <xsl:element name="field_name">service_subscription_list</xsl:element>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="$TerminationDate"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
          <xsl:element name="termination_reason_rd">
            <xsl:value-of select="$TerminationReason"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element> 
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">open_order_found</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">N</xsl:element>          
          <xsl:element name="project_order">
            <xsl:value-of select="$ProjectOrder"/>
          </xsl:element>
          <xsl:element name="supress_confirmation_letter">
            <xsl:value-of select="$SupressConfirmationLetter"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      
        <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
          <xsl:element name="short_description">Automatische Kündigung</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Kündigung der Dienste, die mit dem Rechnungskonto </xsl:text>
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            <xsl:text> verknüpft sind.</xsl:text>
            <xsl:text>&#xA;Client name : </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='USER_NAME']"/>				  
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">open_order_found</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">N</xsl:element>          
        </xsl:element>
      </xsl:element>

      <!-- after errors above no sense to process anything else -->
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
