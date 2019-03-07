<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
  XSLT file for modify Price Plan Subscription

  @author schwarje
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" exclude-result-prefixes="dateutils" version="1.0">
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
		<xsl:element name="client_name">SLS</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			
			<xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
			
			<xsl:variable name="DesiredDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='EFFECTIVE_DATE'] = ''">
						<xsl:value-of select="$Today"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="(count(request-param-list[@name='SELECTED_DESTINATION_LIST']/request-param-list-item) != 0
				or request-param[@name='BEGIN_NUMBER'] != '') 
				and (request-param[@name='STOP_SELECTED_DESTINATION'] = 'Y')">
				<!-- Deactivate Selected destinations -->
				<xsl:element name="CcmFifDeactSelectedDestForPpsCmd">
					<xsl:element name="command_id">deact_sd_1</xsl:element>
					<xsl:element name="CcmFifDeactSelectedDestForPpsInCont">
						<xsl:element name="price_plan_subs_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="price_plan_subscription_id">
									<xsl:value-of select="request-param[@name='PRICE_PLAN_SUBSCRIPTION_ID']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$DesiredDate"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Configure Price Plan -->
			<xsl:element name="CcmFifConfigurePPSCmd">
				<xsl:element name="command_id">config_pps_1</xsl:element>
				<xsl:element name="CcmFifConfigurePPSInCont">
					<xsl:element name="price_plan_subs_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="price_plan_subscription_id">
								<xsl:value-of select="request-param[@name='PRICE_PLAN_SUBSCRIPTION_ID']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
                    <xsl:element name="effective_date">
						<xsl:value-of select="$DesiredDate"/>
					</xsl:element>					
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="pps_option_value">
						<xsl:value-of select="request-param[@name='PPS_OPTION_VALUE']"/>
					</xsl:element>
					<xsl:if test="count(request-param-list[@name='SELECTED_DESTINATION_LIST']/request-param-list-item) != 0
						or request-param[@name='BEGIN_NUMBER'] != ''
						or request-param[@name='END_NUMBER'] != ''">
						<xsl:element name="selected_destinations_list">
							<!-- Selected Destinations -->
							<xsl:for-each select="request-param-list[@name='SELECTED_DESTINATION_LIST']/request-param-list-item">
								<xsl:element name="CcmFifSelectedDestCont">
									<xsl:element name="begin_number">
										<xsl:value-of select="request-param[@name='BEGIN_NUMBER']"/>
									</xsl:element>
									<xsl:if test="request-param[@name='END_NUMBER'] != ''">
										<xsl:element name="end_number">
											<xsl:value-of select="request-param[@name='END_NUMBER']"/>
										</xsl:element>
									</xsl:if>
									<xsl:element name="start_date">
										<xsl:value-of select="$DesiredDate"/>
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
							<xsl:if test="count(request-param-list[@name='SELECTED_DESTINATION_LIST']/request-param-list-item) = 0
								and request-param[@name='BEGIN_NUMBER'] != ''">	
								<xsl:element name="CcmFifSelectedDestCont">
									<xsl:element name="begin_number">
										<xsl:value-of select="request-param[@name='BEGIN_NUMBER']"/>
									</xsl:element>
									<xsl:if test="request-param[@name='END_NUMBER'] != ''">
										<xsl:element name="end_number">
											<xsl:value-of select="request-param[@name='END_NUMBER']"/>
										</xsl:element>
									</xsl:if>
									<xsl:element name="start_date">
										<xsl:value-of select="$DesiredDate"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='GROUP_ID'] != ''">
						<xsl:element name="group_id">
							<xsl:value-of select="request-param[@name='GROUP_ID']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			<xsl:if test="count(request-param-list[@name='CONTRIBUTING_ITEM_LIST']/request-param-list-item) != 0
				or request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] != ''">
				<!-- Add contributing items -->
				<xsl:element name="CcmFifAddModifyContributingItemCmd">
					<xsl:element name="command_id">add_contrib_item_1</xsl:element>
					<xsl:element name="CcmFifAddModifyContributingItemInCont">
						<xsl:element name="price_plan_subscription_id">
							<xsl:value-of select="request-param[@name='PRICE_PLAN_SUBSCRIPTION_ID']"/>
						</xsl:element>
	                    <xsl:element name="effective_date">
							<xsl:value-of select="$DesiredDate"/>
						</xsl:element>					
						<xsl:element name="contributing_item_list">
							<xsl:if test="count(request-param-list[@name='CONTRIBUTING_ITEM_LIST']/request-param-list-item) != 0">
								<xsl:for-each select="request-param-list[@name='CONTRIBUTING_ITEM_LIST']/request-param-list-item">
									<xsl:element name="CcmFifContributingItem">
										<xsl:element name="supported_object_type_rd">
											<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_TYPE_RD']"/>
										</xsl:element>
										<xsl:if test="request-param[@name='STOP_CONTRIBUTING_ITEM'] != 'Y'">
											<xsl:element name="start_date">
												<xsl:value-of select="$DesiredDate"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="request-param[@name='STOP_CONTRIBUTING_ITEM'] = 'Y'">
											<xsl:element name="stop_date">
												<xsl:value-of select="$DesiredDate"/>
											</xsl:element>
										</xsl:if>
										<xsl:element name="hierarchy_inclusion_indicator">
											<xsl:value-of select="request-param[@name='HIERARCHY_INCLUSION_INDICATOR']"/>
										</xsl:element>
										<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'CUSTOMER'">
											<xsl:element name="customer_number">
												<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'ACCOUNT'">
											<xsl:element name="account_number">
												<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'PRODUCT_SUBSC'">
											<xsl:element name="product_subscription_id">
												<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'SERVICE_SUBSC'">
											<xsl:element name="service_subscription_id">
												<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'PROD_GROUP'">
											<xsl:element name="product_group_rd">
												<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
											</xsl:element>
										</xsl:if>
									</xsl:element>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="count(request-param-list[@name='CONTRIBUTING_ITEM_LIST']/request-param-list-item) = 0
								and request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] != ''">
								<xsl:element name="CcmFifContributingItem">
									<xsl:element name="supported_object_type_rd">
										<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_TYPE_RD']"/>
									</xsl:element>
									<xsl:if test="request-param[@name='STOP_CONTRIBUTING_ITEM'] != 'Y'">
										<xsl:element name="start_date">
											<xsl:value-of select="$DesiredDate"/>
										</xsl:element>
									</xsl:if>
									<xsl:if test="request-param[@name='STOP_CONTRIBUTING_ITEM'] = 'Y'">
										<xsl:element name="stop_date">
											<xsl:value-of select="$DesiredDate"/>
										</xsl:element>
									</xsl:if>
									<xsl:element name="hierarchy_inclusion_indicator">
										<xsl:value-of select="request-param[@name='HIERARCHY_INCLUSION_INDICATOR']"/>
									</xsl:element>
									<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'CUSTOMER'">
										<xsl:element name="customer_number">
											<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
										</xsl:element>
									</xsl:if>
									<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'ACCOUNT'">
										<xsl:element name="account_number">
											<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
										</xsl:element>
									</xsl:if>
									<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'PRODUCT_SUBSC'">
										<xsl:element name="product_subscription_id">
											<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
										</xsl:element>
									</xsl:if>
									<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'SERVICE_SUBSC'">
										<xsl:element name="service_subscription_id">
											<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
										</xsl:element>
									</xsl:if>
									<xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'PROD_GROUP'">
										<xsl:element name="product_group_rd">
											<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
										</xsl:element>
									</xsl:if>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='CREATE_CONTACT'] = 'Y'">
				<!-- Create Contact -->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
						<xsl:element name="contact_type_rd">
							<xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
						</xsl:element>
						<xsl:element name="short_description">
							<xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
						</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
