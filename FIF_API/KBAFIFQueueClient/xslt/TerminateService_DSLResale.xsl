
<xsl:if test="$OrderVariant = 'Echte Kündigung'">
  <xsl:element name="CcmFifRaiseErrorCmd">
    <xsl:element name="command_id">orderVariant_error</xsl:element>
    <xsl:element name="CcmFifRaiseErrorInCont">
      <xsl:element name="error_text">The parameter orderVariant has to be provided for terminations of DSLR and may not be "Echte Kündigung"</xsl:element>
    </xsl:element>
  </xsl:element>
</xsl:if>

	
        <!-- find service and connected objects by SS ID -->
    	<xsl:element name="CcmFifFindServiceSubsCmd">
    		<xsl:element name="command_id">find_service_1</xsl:element>
    		<xsl:element name="CcmFifFindServiceSubsInCont">	      
    			<xsl:element name="service_subscription_id">
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
         
         <!-- Ensure that characteristic V0138 on main access service is not equal to OPAL -->
         <xsl:element name="CcmFifValidateCharacteristicValueCmd">
           <xsl:element name="command_id">valid_char_value_1</xsl:element>
           <xsl:element name="CcmFifValidateCharacteristicValueInCont">
             <xsl:element name="service_subscription_ref">
               <xsl:element name="command_id">find_service_1</xsl:element>
               <xsl:element name="field_name">service_subscription_id</xsl:element>
             </xsl:element>
             <xsl:element name="service_char_code">V0138</xsl:element>
             <xsl:element name="configured_value">OPAL</xsl:element>
           </xsl:element>
         </xsl:element>
         
           <!-- Ensure that the termination has not been performed before -->
           <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
             <xsl:element name="command_id">find_cancel_stp__1</xsl:element>
             <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
               <xsl:element name="product_subscription_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">product_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="reason_rd">TERMINATION</xsl:element>
             </xsl:element>
           </xsl:element>
           
           <!-- Terminate Order Form -->
           <xsl:if test="count(request-param[@name='terminateOrderForm']) = '0' 
             or request-param[@name='terminateOrderForm'] != 'N'">
             <xsl:element name="CcmFifTerminateOrderFormCmd">
               <xsl:element name="command_id">terminate_of_1</xsl:element>
               <xsl:element name="CcmFifTerminateOrderFormInCont">
                 <xsl:element name="contract_number">
                   <xsl:value-of select="request-param[@name='contractNumber']"/>
                 </xsl:element>
                 <xsl:element name="termination_date">
                   <xsl:value-of select="request-param[@name='terminationDate']"/>
                 </xsl:element>
                 <xsl:element name="notice_per_start_date">
                   <xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
                 </xsl:element>
                 <xsl:element name="override_restriction">Y</xsl:element>
                 <xsl:element name="termination_reason_rd">
                   <xsl:value-of select="request-param[@name='terminationReason']"/>
                 </xsl:element>
	              <xsl:element name="process_ind_ref">
	                <xsl:element name="command_id">find_service_1</xsl:element>
	                <xsl:element name="field_name">contract_type_rd</xsl:element>
	              </xsl:element>          
	              <xsl:element name="required_process_ind">O</xsl:element>          
               </xsl:element>
             </xsl:element>
           </xsl:if>
           
           <!-- Reconfigure Service Subscription -->
           <xsl:element name="CcmFifReconfigServiceCmd">
             <xsl:element name="command_id">reconf_serv_1</xsl:element>
             <xsl:element name="CcmFifReconfigServiceInCont">
               <xsl:element name="service_subscription_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">service_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="desired_schedule_type">ASAP</xsl:element>
               <xsl:element name="reason_rd">TERMINATION</xsl:element>
               <xsl:element name="service_characteristic_list">
                 <!-- Auftragsvariante --> 
                 <xsl:element name="CcmFifConfiguredValueCont">
                   <xsl:element name="service_char_code">I1011</xsl:element>
                   <xsl:element name="data_type">STRING</xsl:element>
                   <xsl:element name="configured_value">
                     <xsl:value-of select="$OrderVariant"/>
                   </xsl:element>
                 </xsl:element>
                 <!-- Kündigungsgrund -->
                 <xsl:element name="CcmFifConfiguredValueCont">
                   <xsl:element name="service_char_code">V0137</xsl:element>
                   <xsl:element name="data_type">STRING</xsl:element>
                   <xsl:element name="configured_value">
                     <xsl:value-of select="request-param[@name='terminationReason']"/>
                   </xsl:element>
                 </xsl:element>
                 <!-- Aktivierungsdatum -->
                 <xsl:element name="CcmFifConfiguredValueCont">
                   <xsl:element name="service_char_code">V0909</xsl:element>
                   <xsl:element name="data_type">STRING</xsl:element>
                   <xsl:element name="configured_value">
                     <xsl:value-of select="$terminationDateOPM"/>
                   </xsl:element>
                 </xsl:element>
                 <!-- Kündigungsbrief-Versand -->
                 <xsl:if test="(request-param[@name='sendConfirmationLetter'] = 'N')">
                   <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0580</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">Nein</xsl:element>
                   </xsl:element>
                 </xsl:if>
               </xsl:element>
             </xsl:element>
           </xsl:element>
           
           <!-- Add Termination Fee Service -->
           <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
             <xsl:element name="CcmFifAddServiceSubsCmd">
               <xsl:element name="command_id">add_service_1</xsl:element>
               <xsl:element name="CcmFifAddServiceSubsInCont">
                 <xsl:element name="product_subscription_ref">
                   <xsl:element name="command_id">find_service_1</xsl:element>
                   <xsl:element name="field_name">product_subscription_id</xsl:element>
                 </xsl:element>
                 <xsl:element name="service_code">
                   <xsl:value-of select="request-param[@name='terminationFeeServiceCode']"/>
                 </xsl:element>
                 <xsl:element name="parent_service_subs_ref">
                   <xsl:element name="command_id">find_service_1</xsl:element>
                   <xsl:element name="field_name">service_subscription_id</xsl:element>
                 </xsl:element>
                 <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                 <xsl:element name="reason_rd">TERMINATION</xsl:element>

      		<xsl:element name="account_number_ref">
<xsl:element name="command_id">find_service_1</xsl:element>
<xsl:element name="field_name">account_number</xsl:element>
     </xsl:element>
             
                 <xsl:element name="service_characteristic_list">
                 </xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:if>             
           
           <!-- Terminate Product Subscription -->
           <xsl:element name="CcmFifTerminateProductSubsCmd">
             <xsl:element name="command_id">terminate_ps_1</xsl:element>
             <xsl:element name="CcmFifTerminateProductSubsInCont">
               <xsl:element name="product_subscription_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">product_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="desired_date">
                 <xsl:value-of select="request-param[@name='terminationDate']"/>
               </xsl:element>
               <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
               <xsl:element name="reason_rd">TERMINATION</xsl:element>
               <xsl:element name="auto_customer_order">N</xsl:element>
               <xsl:element name="detailed_reason_rd">
                 <xsl:value-of select="request-param[@name='detailedReason']"/>	
               </xsl:element>
             </xsl:element>
           </xsl:element>
           
           <!-- Create Customer Order for Reconfiguration -->
           <xsl:element name="CcmFifCreateCustOrderCmd">
             <xsl:element name="command_id">create_co_1</xsl:element>
             <xsl:element name="CcmFifCreateCustOrderInCont">
               <xsl:element name="customer_number_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="customer_tracking_id">
                 <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
               </xsl:element>
               <xsl:element name="provider_tracking_no">
                 <xsl:choose>
                   <xsl:when test="request-param[@name='providerTrackingNumberChange'] != ''">
                     <xsl:value-of select="request-param[@name='providerTrackingNumberChange']" />
                   </xsl:when>
                   <xsl:otherwise>001</xsl:otherwise>
                 </xsl:choose>
               </xsl:element>			  	
               <xsl:element name="service_ticket_pos_list">
                 <xsl:element name="CcmFifCommandRefCont">
                   <xsl:element name="command_id">reconf_serv_1</xsl:element>
                   <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                 </xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:element>
           
           <!-- Create Customer Order for Add Service -->
           <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
             <xsl:element name="CcmFifCreateCustOrderCmd">
               <xsl:element name="command_id">create_co_3</xsl:element>
               <xsl:element name="CcmFifCreateCustOrderInCont">
                 <xsl:element name="customer_number_ref">
                   <xsl:element name="command_id">find_service_1</xsl:element>
                   <xsl:element name="field_name">customer_number</xsl:element>
                 </xsl:element>
                 <xsl:element name="parent_customer_order_ref">
                   <xsl:element name="command_id">create_co_1</xsl:element>
                   <xsl:element name="field_name">customer_order_id</xsl:element>
                 </xsl:element>
                 <xsl:element name="customer_tracking_id">
                   <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                 </xsl:element>
                 <xsl:element name="service_ticket_pos_list">
                   <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_1</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                   </xsl:element>
                 </xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:if>             
           
           <!-- Create Customer Order for Termination -->
           <xsl:element name="CcmFifCreateCustOrderCmd">
             <xsl:element name="command_id">create_co_2</xsl:element>
             <xsl:element name="CcmFifCreateCustOrderInCont">
               <xsl:element name="customer_number_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="parent_customer_order_ref">
                 <xsl:element name="command_id">create_co_1</xsl:element>
                 <xsl:element name="field_name">customer_order_id</xsl:element>
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
           
           <!-- Release Customer Order for Reconfiguration -->
           <xsl:element name="CcmFifReleaseCustOrderCmd">
             <xsl:element name="CcmFifReleaseCustOrderInCont">
               <xsl:element name="customer_number_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="customer_order_ref">
                 <xsl:element name="command_id">create_co_1</xsl:element>
                 <xsl:element name="field_name">customer_order_id</xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:element>
           
           <!-- Release Customer Order for Add Service -->
           <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
             <xsl:element name="CcmFifReleaseCustOrderCmd">
               <xsl:element name="CcmFifReleaseCustOrderInCont">
                 <xsl:element name="customer_number_ref">
                   <xsl:element name="command_id">find_service_1</xsl:element>
                   <xsl:element name="field_name">customer_number</xsl:element>
                 </xsl:element>
                 <xsl:element name="customer_order_ref">
                   <xsl:element name="command_id">create_co_3</xsl:element>
                   <xsl:element name="field_name">customer_order_id</xsl:element>
                 </xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:if>             
           
           <!-- Release Customer Order for Termination -->
           <xsl:element name="CcmFifReleaseCustOrderCmd">
             <xsl:element name="CcmFifReleaseCustOrderInCont">
               <xsl:element name="customer_number_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="customer_order_ref">
                 <xsl:element name="command_id">create_co_2</xsl:element>
                 <xsl:element name="field_name">customer_order_id</xsl:element>
               </xsl:element>
             </xsl:element>
           </xsl:element>
           
           <!-- Create Contact for the Service Termination -->
           <xsl:element name="CcmFifCreateContactCmd">
             <xsl:element name="CcmFifCreateContactInCont">
               <xsl:element name="customer_number_ref">
                 <xsl:element name="command_id">find_service_1</xsl:element>
                 <xsl:element name="field_name">customer_number</xsl:element>
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
                 <xsl:text>&#xA;DeactivateOnlineAccount: Y</xsl:text>
                 <xsl:text>&#xA;SendConfirmationLetter: </xsl:text>
                 <xsl:if test="(request-param[@name='terminationReason'] = 'ZTCOM') or (request-param[@name='terminationReason'] = 'UMZN')">N</xsl:if>                                 
                 <xsl:if test="(request-param[@name='terminationReason'] != 'ZTCOM') and (request-param[@name='terminationReason'] != 'UMZN')">
                   <xsl:value-of select="request-param[@name='sendConfirmationLetter']"/>
                 </xsl:if>                                                               
                 <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                 <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
               </xsl:element>
             </xsl:element>
           </xsl:element>                  
                  
                  
