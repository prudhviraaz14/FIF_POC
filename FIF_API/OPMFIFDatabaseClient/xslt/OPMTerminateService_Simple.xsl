
<xsl:element name="Command_List">
	
	<xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] = ''">
		<!-- Terminate Order Form -->
		<xsl:element name="CcmFifTerminateOrderFormCmd">
			<xsl:element name="command_id">terminate_of_1</xsl:element>
			<xsl:element name="CcmFifTerminateOrderFormInCont">
				<xsl:element name="contract_number">
					<xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
				</xsl:element>
				<xsl:element name="termination_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>
				<xsl:element name="notice_per_start_date">
					<xsl:value-of select="request-param[@name='NOTICE_PERIOD_START_DATE']"/>
				</xsl:element>
				<xsl:element name="override_restriction">Y</xsl:element>
				<xsl:element name="termination_reason_rd">
					<xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>
	

	<xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
		<!-- find service and connected objects by SS ID -->
    	<xsl:element name="CcmFifFindServiceSubsCmd">
    		<xsl:element name="command_id">find_service_1</xsl:element>
    		<xsl:element name="CcmFifFindServiceSubsInCont">	      
    			<xsl:element name="service_subscription_id">
    				<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
        <!-- Cancel some incomplet stps if they exists -->			
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
    	
		<!-- Terminate Product Subscription  -->
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
	    			<xsl:if test="request-param[@name='reasonRd'] != ''">
	    				<xsl:element name="reason_rd">
	    					<xsl:value-of select="request-param[@name='REASON_RD']"/>
	    				</xsl:element>
	    			</xsl:if>
	    			<xsl:if test="request-param[@name='reasonRd'] = ''">
	    				<xsl:element name="reason_rd">TERMINATION</xsl:element>
	    			</xsl:if>	      
	    			<xsl:element name="auto_customer_order">N</xsl:element>         
	    			<xsl:element name="detailed_reason_rd">
	    				<xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
	    			</xsl:element>
	    		</xsl:element>
	    	</xsl:element>
				
    	<!-- Create Customer Order for Termination -->
    	<xsl:element name="CcmFifCreateCustOrderCmd">
    		<xsl:element name="command_id">create_co_1</xsl:element>
    		<xsl:element name="CcmFifCreateCustOrderInCont">
    			<xsl:element name="customer_number">
    				<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
    			</xsl:element>
    			<xsl:element name="customer_tracking_id">
    				<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
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
    			<xsl:element name="customer_number">
    				<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
    			</xsl:element>
    			<xsl:element name="customer_order_ref">
    				<xsl:element name="command_id">create_co_1</xsl:element>
    				<xsl:element name="field_name">customer_order_id</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
    </xsl:if>	

	<!-- Create Contact for the  Termination -->
	<xsl:element name="CcmFifCreateContactCmd">
		<xsl:element name="CcmFifCreateContactInCont">
			<xsl:element name="customer_number">
				<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
			</xsl:element>
			<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
			<xsl:element name="short_description">Automatische Kündigung</xsl:element>
			<xsl:element name="long_description_text">
				<xsl:text>Transaction ID: </xsl:text>
				<xsl:value-of select="request-param[@name='transactionID']"/>
				<xsl:text>&#xA;Contract Number: </xsl:text>
				<xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
				<xsl:text>&#xA;Service Subscription ID: </xsl:text>
				<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
				<xsl:text>&#xA;Termination Reason: </xsl:text>
				<xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
			</xsl:element>
		</xsl:element>
	</xsl:element>
	
</xsl:element>
