<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a FIF request for a discount contract.

	@author banania
-->
<!DOCTYPE XSL [
<!ENTITY CreateBasicContractData SYSTEM "CreateBasicContractData.xsl">
<!ENTITY CreateDiscountServiceSubs SYSTEM "CreateDiscountServiceSubs.xsl">
]>


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
		<xsl:element name="Command_List">
		
		<xsl:variable name="contractName">Rabatt Vertrag</xsl:variable>
			
		<xsl:variable name="contributingItemObjectType">
			<xsl:choose>
				<xsl:when test="request-param[@name='contributingItemType'] != ''">
					<xsl:value-of select="request-param[@name='contributingItemType']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="request-param[@name='productCode'] = 'V9022'
							or request-param[@name='productCode'] = 'V9023'">
							<xsl:text>ACCOUNT</xsl:text>    
						</xsl:when>
						<xsl:otherwise>CUSTOMER</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose> 
		</xsl:variable>
		<xsl:variable name="actualdate"  select="request-param[@name='desiredDate']"/>
		<xsl:variable name="today"  select="dateutils:getCurrentDate()"/>
		<xsl:variable name="Yesterday" select="dateutils:createFIFDateOffset($actualdate, 'DATE', '-1')"/>
		<xsl:variable name="desireDate">
				  <xsl:choose>
				 	<xsl:when test ="dateutils:compareString($actualdate,$today)">
						<xsl:value-of select="$Yesterday"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$actualdate"/>
					</xsl:otherwise>
				</xsl:choose> 
		</xsl:variable>

		<!-- Get Customer number if not provided-->
		<xsl:if test="(request-param[@name='customerNumber'] = '')">
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
			
		<!-- Get Account number if not provided -->
		<xsl:if test="(request-param[@name='accountNumber'] = '')">
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
			
		&CreateBasicContractData;
		&CreateDiscountServiceSubs;


		<!-- Get price plan data -->
		<xsl:element name="CcmFifGetPricePlanDataForProductSubsCmd">
			<xsl:element name="command_id">get_price_plan_data</xsl:element>
			<xsl:element name="CcmFifGetPricePlanDataForProductSubsInCont">
				<xsl:element name="product_subscription_id_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="dateutils:getCurrentDate()"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- Add contributing item -->
		<xsl:element name="CcmFifAddModifyContributingItemCmd">
			<xsl:element name="command_id">add_contributing_item</xsl:element>
			<xsl:element name="CcmFifAddModifyContributingItemInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="price_plan_code">
					<xsl:value-of select="request-param[@name='pricePlanCode']"/>
				</xsl:element>
				<xsl:element name="contributing_item_list">
					<xsl:element name="CcmFifContributingItem">
						<xsl:element name="supported_object_type_rd">
							<xsl:value-of select="$contributingItemObjectType"/>
						</xsl:element>
						<xsl:element name="start_date">
						</xsl:element>
						<xsl:element name="hierarchy_inclusion_indicator">
							<xsl:value-of select="request-param[@name='hierarchyInclusionIndicator']"/>
							</xsl:element>
						<xsl:if test="$contributingItemObjectType = 'ACCOUNT'">
							<xsl:if test="request-param[@name='accountNumber']=''">
								<xsl:element name="account_number_ref">
									<xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
									<xsl:element name="field_name">parameter_value</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='accountNumber']!=''">
								<xsl:element name="account_number">
									<xsl:value-of select="request-param[@name='accountNumber']"/>
								</xsl:element>
							</xsl:if>
						</xsl:if>
						<xsl:if test="$contributingItemObjectType = 'CUSTOMER'">
							<xsl:if test="request-param[@name='customerNumber']=''">
								<xsl:element name="customer_number_ref">
									<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
									<xsl:element name="field_name">parameter_value</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='customerNumber']!=''">
								<xsl:element name="customer_number">
									<xsl:value-of select="request-param[@name='customerNumber']"/>
								</xsl:element>
							</xsl:if>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>  
			
		<xsl:if test="request-param[@name='pricePlanOptionValue'] != '' 
			or request-param[@name='discountGroupId'] != ''">
			<!-- Configure Price Plan -->
			<xsl:element name="CcmFifConfigurePPSCmd">
				<xsl:element name="command_id">config_pps_1</xsl:element>
				<xsl:element name="CcmFifConfigurePPSInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="price_plan_code">
						<xsl:value-of select="request-param[@name='pricePlanCode']"/>
					</xsl:element>	                
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>					
					<xsl:element name="pps_option_value">
						<xsl:value-of select="request-param[@name='pricePlanOptionValue']"/>
					</xsl:element>
					<xsl:element name="group_id">
						<xsl:value-of select="request-param[@name='discountGroupId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>			
			
	    <!-- Create contact for Service Addition -->
	    <xsl:if test="request-param[@name='productCommitmentNumber']=''">
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">create_contact_1</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:if test="request-param[@name='customerNumber']=''">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber']!=''">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="contact_type_rd">CREATE_DISCOUNT</xsl:element>
				<xsl:element name="short_description">
					<xsl:text>Anlage Discount Contract.</xsl:text>
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text>&#xA;Discount Contract has been created on:</xsl:text>
					<xsl:value-of select="request-param[@name='desiredDate']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	    </xsl:if>

        <!-- Create contact  for Service Addition -->
	    <xsl:if test="request-param[@name='productCommitmentNumber']!=''">
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">create_contact_1_ps</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:if test="request-param[@name='customerNumber']=''">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber']!=''">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="contact_type_rd">CREATE_DISCOUNT</xsl:element>
				<xsl:element name="short_description">
					<xsl:text>Anlage Discount PS.</xsl:text>
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text>&#xA;Discount Product subscription has been added on:</xsl:text>
					<xsl:value-of select="request-param[@name='desiredDate']"/>
					<xsl:text>&#xA;Username:</xsl:text>
					<xsl:value-of select="request-param[@name='userName']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		</xsl:if>

		<!--  Create  external notification if the requestListId is set  -->
		<xsl:if test="request-param[@name='requestListId'] != ''">
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">CreateDiscountContract</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">DISCOUNT_SERVICE_SUBSCRIPTION_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_service_subs</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_product_subscription_1</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co_1</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>

	</xsl:element>

	</xsl:template>
</xsl:stylesheet>
