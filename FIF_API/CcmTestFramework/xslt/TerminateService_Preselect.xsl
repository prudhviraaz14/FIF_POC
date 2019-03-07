
		<xsl:element name="CcmFifReadExternalNotificationCmd">
			<xsl:element name="command_id">read_ext_noti_1</xsl:element>
			<xsl:element name="CcmFifReadExternalNotificationInCont">
				<xsl:element name="transaction_id">
					<xsl:value-of select="request-param[@name='requestListId']"/>
				</xsl:element>
				<xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
			</xsl:element>
		</xsl:element>	
	
        <!-- find service and connected objects by SS ID -->
    	<xsl:element name="CcmFifFindServiceSubsCmd">
    		<xsl:element name="command_id">find_service_1</xsl:element>
    		<xsl:element name="CcmFifFindServiceSubsInCont">	      
    			<xsl:element name="service_subscription_id">
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
	
	<!-- Terminate Order Form -->
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
    	
    	<!-- Terminate Product Subscription -->
    	<xsl:element name="CcmFifTerminateProductSubsCmd">
    		<xsl:element name="command_id">terminate_ps_1</xsl:element>
    		<xsl:element name="CcmFifTerminateProductSubsInCont">
    			<xsl:element name="product_subscription_ref">
    				<xsl:element name="command_id">find_service_1</xsl:element>
    				<xsl:element name="field_name">product_subscription_id</xsl:element>
    			</xsl:element>   			
    			<xsl:element name="desired_date">
    				<xsl:value-of select="$TerminationDate"/>
    			</xsl:element>
    			<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
    			<xsl:element name="reason_rd">TERMINATION</xsl:element>	      
    			<xsl:element name="auto_customer_order">N</xsl:element>         
                <xsl:element name="detailed_reason_rd">
                  <xsl:value-of select="request-param[@name='detailedReason']"/>	
                </xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
    	<!-- Create Customer Order for Termination -->
    	<xsl:element name="CcmFifCreateCustOrderCmd">
    		<xsl:element name="command_id">create_co_1</xsl:element>
    		<xsl:element name="CcmFifCreateCustOrderInCont">
    			<xsl:element name="customer_number">
    				<xsl:value-of select="request-param[@name='customerNumber']"/>
    			</xsl:element>
    			<xsl:element name="customer_tracking_id">
    				<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
    			</xsl:element>	
    			<xsl:element name="provider_tracking_no">
    				<xsl:choose>
    					<xsl:when test="request-param[@name='providerTrackingNumberDefault'] != ''">
    						<xsl:value-of select="request-param[@name='providerTrackingNumberDefault']" />
    					</xsl:when>
    					<xsl:otherwise>002d</xsl:otherwise>
    				</xsl:choose>
    			</xsl:element>
    			<xsl:element name="offset_release_days">5</xsl:element>  	 					
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
    			<xsl:element name="customer_number">
    				<xsl:value-of select="request-param[@name='customerNumber']"/>
    			</xsl:element>
    			<xsl:element name="customer_order_ref">
    				<xsl:element name="command_id">create_co_1</xsl:element>
    				<xsl:element name="field_name">customer_order_id</xsl:element>
    			</xsl:element>
    			<xsl:element name="parent_customer_order_id_ref">
    				<xsl:element name="command_id">read_ext_noti_1</xsl:element>
    				<xsl:element name="field_name">parameter_value</xsl:element>
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
    				<xsl:text>Kündigung der Produktnutzung für Dienst </xsl:text>
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
    				<xsl:text> durch </xsl:text>
    				<xsl:value-of select="request-param[@name='clientName']"/> 
    				<xsl:text>.&#xA;TransactionID: </xsl:text>
    				<xsl:value-of select="request-param[@name='transactionID']"/>
    				<xsl:text>&#xA;User name: </xsl:text>
    				<xsl:value-of select="request-param[@name='userName']"/>				  
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
