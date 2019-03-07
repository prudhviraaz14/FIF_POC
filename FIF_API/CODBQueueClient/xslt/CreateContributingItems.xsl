<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- XSLT file for creating an Add Feature Service FIF request @author goethalo -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	exclude-result-prefixes="dateutils">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"
		doctype-system="fif_transaction.dtd" />
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="request-params">
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']" />
		</xsl:element>
		<xsl:element name="client_name">
			<xsl:value-of select="request-param[@name='clientName']" />
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name" />
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']" />
		</xsl:element>

		<xsl:element name="Command_List">

			<xsl:variable name="serviceSubscriptionId">
				<xsl:value-of select="request-param[@name='serviceSubscriptionId']" />
			</xsl:variable>

			<xsl:variable name="requestListId">
				<xsl:value-of select="request-param[@name='requestListId']" />
			</xsl:variable>

			<xsl:variable name="isMovedService">
				<xsl:value-of select="request-param[@name='isMovedService']" />
			</xsl:variable>

			<xsl:variable name="action">
				<xsl:value-of select="request-param[@name='action']" />
			</xsl:variable>

          <!-- do a dummy command to avoid a parsing error in the CcmFifInterface --> 
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">dummyaction</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">dummyaction</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>

			<xsl:for-each
				select="request-param-list[@name='configuredServiceList']/request-param-list-item">
				<xsl:variable name="serviceCode">
					<xsl:value-of select="request-param[@name='serviceCode']" />
				</xsl:variable>

				<xsl:if test="$action != 'remove' and $isMovedService != 'Y' and
          			count(../../request-param-list[@name='existingServiceList']/request-param-list-item[
          			request-param[@name='serviceCode'] = $serviceCode]) = 0">

					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">readUseProductSubscriptionId</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="$requestListId" />
								<xsl:text>-</xsl:text>
								<xsl:value-of select="$serviceSubscriptionId" />
								<xsl:text>-</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']" />
							</xsl:element>
							<xsl:element name="parameter_name">useProductSubscriptionId</xsl:element>
							<xsl:element name="ignore_empty_result">Y</xsl:element>
						</xsl:element>
					</xsl:element>

					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">readProductSubscriptionId</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="$requestListId" />
								<xsl:text>-</xsl:text>
								<xsl:value-of select="$serviceSubscriptionId" />
								<xsl:text>-</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']" />
							</xsl:element>
							<xsl:element name="parameter_name">productSubscriptionId</xsl:element>
							<xsl:element name="ignore_empty_result">Y</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">readUseProductSubscriptionId</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>

					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">readStartDate</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="$requestListId" />
								<xsl:text>-</xsl:text>
								<xsl:value-of select="$serviceSubscriptionId" />
								<xsl:text>-</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']" />
							</xsl:element>
							<xsl:element name="parameter_name">startDate</xsl:element>
							<xsl:element name="ignore_empty_result">Y</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">readUseProductSubscriptionId</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>

					<xsl:element name="CcmFifAddModifyContributingItemCmd">
						<xsl:element name="command_id">
							<xsl:text>add_contributing_item_</xsl:text>
							<xsl:value-of select="position()" />
						</xsl:element>
						<xsl:element name="CcmFifAddModifyContributingItemInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">readProductSubscriptionId</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:value-of select="$serviceCode" />
							</xsl:element>
							<xsl:element name="effective_date_ref">
								<xsl:element name="command_id">readStartDate</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="contributing_item_list">
								<xsl:element name="CcmFifContributingItem">
									<xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
									<xsl:element name="start_date_ref">
										<xsl:element name="command_id">readStartDate</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
									<xsl:element name="service_subscription_id">
										<xsl:value-of select="$serviceSubscriptionId" />
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">readUseProductSubscriptionId</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>
							<xsl:element name="no_price_plan_error">N</xsl:element>
							<xsl:element name="ignore_contributing_item_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>

					<xsl:element name="CcmFifAddModifyContributingItemCmd">
						<xsl:element name="command_id">
							<xsl:text>add_contributing_item_</xsl:text>
							<xsl:value-of select="position()" />
						</xsl:element>
						<xsl:element name="CcmFifAddModifyContributingItemInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">readProductSubscriptionId</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:value-of select="$serviceCode" />
							</xsl:element>
							<xsl:element name="effective_date_ref">
								<xsl:element name="command_id">readStartDate</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="contributing_item_list">
								<xsl:element name="CcmFifContributingItem">
									<xsl:element name="supported_object_type_rd">PRODUCT_SUBSC</xsl:element>
									<xsl:element name="start_date_ref">
										<xsl:element name="command_id">readStartDate</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
									<xsl:element name="product_subscription_ref">
										<xsl:element name="command_id">readProductSubscriptionId</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">readUseProductSubscriptionId</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
							<xsl:element name="no_price_plan_error">N</xsl:element>
							<xsl:element name="ignore_contributing_item_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>

				</xsl:if>
			</xsl:for-each>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
