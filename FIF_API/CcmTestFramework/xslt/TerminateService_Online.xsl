
<xsl:element name="CcmFifFindServiceSubsCmd">
	<xsl:element name="command_id">find_online_service</xsl:element>
	<xsl:element name="CcmFifFindServiceSubsInCont">
		<xsl:element name="contract_number">
			<xsl:value-of select="request-param[@name='contractNumber']"/>
		</xsl:element>
		<xsl:element name="service_code">I1040</xsl:element>
		<xsl:element name="no_service_error">N</xsl:element>
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifReadExternalNotificationCmd">
	<xsl:element name="command_id">read_external_notification_1</xsl:element>
	<xsl:element name="CcmFifReadExternalNotificationInCont">
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='requestListId']"/>
		</xsl:element>
		<xsl:element name="parameter_name">TERM_SERVICE_SUBSCRIPTION_ID</xsl:element>  
		<xsl:element name="ignore_empty_result">Y</xsl:element>                      
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifReadExternalNotificationCmd">
	<xsl:element name="command_id">read_external_notification_2</xsl:element>
	<xsl:element name="CcmFifReadExternalNotificationInCont">
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='requestListId']"/>
		</xsl:element>
		<xsl:element name="parameter_name">TERM_CUSTOMER_ORDER_ID</xsl:element>  
		<xsl:element name="ignore_empty_result">Y</xsl:element>                      
	</xsl:element>
</xsl:element>

<!-- look for a Voice Bundle  (item) -->
<xsl:element name="CcmFifFindBundleCmd">
	<xsl:element name="command_id">find_bundle_1</xsl:element>
	<xsl:element name="CcmFifFindBundleInCont">
		<xsl:element name="supported_object_id_ref">
			<xsl:element name="command_id">read_external_notification_1</xsl:element>
			<xsl:element name="field_name">parameter_value</xsl:element>
		</xsl:element>
		<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">read_external_notification_1</xsl:element>
			<xsl:element name="field_name">value_found</xsl:element>          	
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>    
	</xsl:element>
</xsl:element>

<!-- look for an Voice service in that bundle -->
<xsl:element name="CcmFifFindBundleCmd">
	<xsl:element name="command_id">find_bundle_onl_1</xsl:element>
	<xsl:element name="CcmFifFindBundleInCont">
		<xsl:element name="bundle_id_ref">
			<xsl:element name="command_id">find_bundle_1</xsl:element>
			<xsl:element name="field_name">bundle_id</xsl:element>
		</xsl:element>
		<xsl:element name="bundle_item_type_rd">ONLINE_SERVICE</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">find_bundle_1</xsl:element>
			<xsl:element name="field_name">bundle_found</xsl:element>          	
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>   
	</xsl:element>
</xsl:element>

<!-- look for an Voice service in that bundle -->
<xsl:element name="CcmFifFindBundleCmd">
	<xsl:element name="command_id">find_bundle_dslonl_1</xsl:element>
	<xsl:element name="CcmFifFindBundleInCont">
		<xsl:element name="bundle_id_ref">
			<xsl:element name="command_id">find_bundle_1</xsl:element>
			<xsl:element name="field_name">bundle_id</xsl:element>
		</xsl:element>
		<xsl:element name="bundle_item_type_rd">DSLONL_SERVICE</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">find_bundle_1</xsl:element>
			<xsl:element name="field_name">bundle_found</xsl:element>            	
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>   
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifFindServiceSubsCmd">
	<xsl:element name="command_id">find_service_onl_1</xsl:element>
	<xsl:element name="CcmFifFindServiceSubsInCont">
		<xsl:element name="service_subscription_id_ref">
			<xsl:element name="command_id">find_bundle_onl_1</xsl:element>
			<xsl:element name="field_name">supported_object_id</xsl:element>
		</xsl:element>
		<xsl:element name="effective_date">
			<xsl:value-of select="request-param[@name='terminationDate']"/>
		</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">find_bundle_onl_1</xsl:element>
			<xsl:element name="field_name">bundle_found</xsl:element>            	
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>        
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifFindServiceSubsCmd">
	<xsl:element name="command_id">find_service_onl_1</xsl:element>
	<xsl:element name="CcmFifFindServiceSubsInCont">
		<xsl:element name="service_subscription_id_ref">
			<xsl:element name="command_id">find_bundle_dslonl_1</xsl:element>
			<xsl:element name="field_name">supported_object_id</xsl:element>
		</xsl:element>
		<xsl:element name="effective_date">
			<xsl:value-of select="request-param[@name='terminationDate']"/>
		</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">find_bundle_dslonl_1</xsl:element>
			<xsl:element name="field_name">bundle_found</xsl:element>            	
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>        
	</xsl:element>
</xsl:element>

<!-- Terminate Product Subscription -->
<xsl:element name="CcmFifTerminateProductSubsCmd">
	<xsl:element name="command_id">terminate_ps_1</xsl:element>
	<xsl:element name="CcmFifTerminateProductSubsInCont">
		<xsl:element name="product_subscription_ref">
			<xsl:element name="command_id">find_service_onl_1</xsl:element>
			<xsl:element name="field_name">product_subscription_id</xsl:element>
		</xsl:element>   			
		<xsl:element name="desired_date">
			<xsl:value-of select="request-param[@name='terminationDate']"/>
		</xsl:element>
		<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		<xsl:element name="reason_rd">TERMINATION</xsl:element>	      
		<xsl:element name="auto_customer_order">N</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">find_service_onl_1</xsl:element>
			<xsl:element name="field_name">service_found</xsl:element>         	
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>     			         
	</xsl:element>
</xsl:element>

<!-- Terminate Product Subscription -->
<xsl:element name="CcmFifTerminateProductSubsCmd">
	<xsl:element name="command_id">terminate_ps_1</xsl:element>
	<xsl:element name="CcmFifTerminateProductSubsInCont">
		<xsl:element name="product_subscription_ref">
			<xsl:element name="command_id">find_online_service</xsl:element>
			<xsl:element name="field_name">product_subscription_id</xsl:element>
		</xsl:element>   			
		<xsl:element name="desired_date">
			<xsl:value-of select="request-param[@name='terminationDate']"/>
		</xsl:element>
		<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		<xsl:element name="reason_rd">TERMINATION</xsl:element>	      
		<xsl:element name="auto_customer_order">N</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">read_external_notification_1</xsl:element>
			<xsl:element name="field_name">value_found</xsl:element>          	
		</xsl:element>
		<xsl:element name="required_process_ind">N</xsl:element>     			         
	</xsl:element>
</xsl:element>

<xsl:if test="request-param[@name='terminationFeeServiceCode'] != '' and
	request-param[@name='serviceSubscriptionId'] != ''">
	
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
</xsl:if>
	
<!-- Create Customer Order for Termination -->
<xsl:element name="CcmFifCreateCustOrderCmd">
	<xsl:element name="command_id">ts_create_co_1</xsl:element>
	<xsl:element name="CcmFifCreateCustOrderInCont">
		<xsl:element name="customer_number">
			<xsl:value-of select="request-param[@name='customerNumber']"/>
		</xsl:element>
		<xsl:element name="parent_customer_order_ref">
			<xsl:element name="command_id">read_external_notification_2</xsl:element>
			<xsl:element name="field_name">parameter_value</xsl:element>
		</xsl:element>      			
		<xsl:element name="customer_tracking_id">
			<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
		</xsl:element>	
		<xsl:element name="provider_tracking_no">
			<xsl:choose>
				<xsl:when test="request-param[@name='providerTrackingNumberDefault'] != ''">
					<xsl:value-of select="request-param[@name='providerTrackingNumberDefault']" />
				</xsl:when>
				<xsl:otherwise>002i</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="ignore_empty_list_ind">Y</xsl:element>	
		<xsl:element name="service_ticket_pos_list">
			<xsl:element name="CcmFifCommandRefCont">
				<xsl:element name="command_id">terminate_ps_1</xsl:element>
				<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:element>

<xsl:if test="request-param[@name='terminationFeeServiceCode'] != '' and
	request-param[@name='serviceSubscriptionId'] != ''">
	
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

<!-- Release Customer Order for Termination -->
<xsl:element name="CcmFifReleaseCustOrderCmd">
	<xsl:element name="CcmFifReleaseCustOrderInCont">
		<xsl:element name="customer_number">
			<xsl:value-of select="request-param[@name='customerNumber']"/>
		</xsl:element>
		<xsl:element name="customer_order_ref">
			<xsl:element name="command_id">ts_create_co_1</xsl:element>
			<xsl:element name="field_name">customer_order_id</xsl:element>
		</xsl:element>
		<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
		<xsl:element name="parent_customer_order_id_ref">
			<xsl:element name="command_id">read_ext_noti_1</xsl:element>
			<xsl:element name="field_name">parameter_value</xsl:element>
		</xsl:element>	
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifModifyBundleItemCmd">
	<xsl:element name="CcmFifModifyBundleItemInCont">
		<xsl:element name="bundle_id_ref">
			<xsl:element name="command_id">find_bundle_1</xsl:element>
			<xsl:element name="field_name">bundle_id</xsl:element>
		</xsl:element>
		<xsl:element name="supported_object_id_ref">
			<xsl:element name="command_id">find_service_onl_1</xsl:element>
			<xsl:element name="field_name">service_subscription_id</xsl:element>
		</xsl:element>
		<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
		<xsl:element name="action_name">MODIFY</xsl:element>
		<xsl:element name="future_indicator">T</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">find_bundle_1</xsl:element>
			<xsl:element name="field_name">bundle_found</xsl:element>
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>
	</xsl:element>
</xsl:element>
