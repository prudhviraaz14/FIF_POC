<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- XSLT file for for reconfiguring service subscriptions for Other function -->

<xsl:stylesheet exclude-result-prefixes="dateutils"
	version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
		indent="yes" method="xml" />
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params" />
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
	
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
	
 
		<!-- Calculate today and one day before the desired date -->
		<xsl:element name="Command_List">

			<xsl:variable name="productCode">
				<xsl:value-of select="request-param[@name='productCode']" />
			</xsl:variable>

			<xsl:variable name="serviceCode">
				<xsl:value-of select="request-param[@name='serviceCode']" />
			</xsl:variable>

			<xsl:variable name="desiredDate">
				<xsl:value-of select="request-param[@name='desiredDate']" />
			</xsl:variable>

			<xsl:element name="CcmFifFindServiceSubsCmd">
				<!-- Find service -->
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='serviceSubscriptionId']" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
				<xsl:if test="
					request-param[@name='configuredValue'] != '' or
					request-param[@name='configuredName'] != '' or
					request-param[@name='configuredLocalNumber'] != '' or
					request-param[@name='configuredCity'] != ''">			
					<xsl:element name="CcmFifGetServiceCharCodeCmd">
						<xsl:element name="command_id"><xsl:text>get_servicechar_code_</xsl:text>
							<xsl:value-of select="request-param[@name='parameterName']" />
						</xsl:element>
						<xsl:element name="CcmFifGetServiceCharCodeInCont">
							<xsl:element name="element_name">
								<xsl:value-of select="request-param[@name='parameterName']" />
							</xsl:element>
							<xsl:element name="element_path">
								<xsl:value-of select="request-param[@name='path']" />
							</xsl:element>
							<xsl:element name="source_service_code">
								<xsl:choose>
									<xsl:when test="$serviceCode = ''">-</xsl:when>
									<xsl:otherwise><xsl:value-of select="$serviceCode"/></xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<xsl:if test="
					request-param[@name='parameterName'] = 'lineOwnerAddress' and
					request-param[@name='configuredCity'] != ''">
					<xsl:element name="CcmFifGetEntityCmd">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="CcmFifGetEntityInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				
					<xsl:element name="CcmFifCreateAddressCmd">
					    <xsl:element name="command_id">
							<xsl:text>create_address_</xsl:text>
							<xsl:value-of select="request-param[@name='parameterName']"/>
					    </xsl:element>
						<xsl:element name="CcmFifCreateAddressInCont">
							<xsl:element name="entity_ref">
								<xsl:element name="command_id">get_entity</xsl:element>
								<xsl:element name="field_name">entity_id</xsl:element>
							</xsl:element>
							<xsl:element name="address_type"/>
							<xsl:element name="street_name">
								<xsl:value-of select="request-param[@name='configuredStreet']" />
							</xsl:element>
							<xsl:element name="street_number">
								<xsl:value-of select="request-param[@name='configuredStreetNumber']" />
							</xsl:element>
							<xsl:element name="street_number_suffix">
								<xsl:value-of select="request-param[@name='configuredStreetNumberSuffix']" />
							</xsl:element>
							<xsl:element name="postal_code">
								<xsl:value-of select="request-param[@name='configuredPostalCode']" />
							</xsl:element>
							<xsl:element name="city_name">
								<xsl:value-of select="request-param[@name='configuredCity']" />
							</xsl:element>
							<xsl:element name="city_suffix_name">
								<xsl:value-of select="request-param[@name='configuredCitySuffix']" />
							</xsl:element>
							<xsl:element name="country_code">
								<xsl:choose>
									<xsl:when test="request-param[@name='configuredCountry'] != ''">
										<xsl:value-of select="request-param[@name='configuredCountry']"/>
									</xsl:when>
									<xsl:otherwise>DE</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
							<xsl:element name="address_additional_text">
								<xsl:value-of select="request-param[@name='configuredAdditionalAddressDescription']"/>
							</xsl:element>
							<xsl:element name="set_primary_address">N</xsl:element>
							<xsl:element name="ignore_existing_address">Y</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
			
			<!-- Reconfigure -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_main_service</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate" />
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:for-each
							select="request-param-list[@name='parameterList']/request-param-list-item">
							<xsl:variable name="dataType">
								<xsl:choose>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'">MAIN_ACCESS_NUM</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">ACC_NUM_RANGE</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">ACC_NUM_RANGE</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">ACC_NUM_RANGE</xsl:when>
									<xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">SERVICE_LOCATION</xsl:when>
    								<xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    								<xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">ADDRESS</xsl:when>
									<xsl:otherwise>STRING</xsl:otherwise>	
								</xsl:choose>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$dataType = 'STRING' and request-param[@name='configuredValue'] != ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code_ref">
											<xsl:element name="command_id"><xsl:text>get_servicechar_code_</xsl:text>
												<xsl:value-of select="request-param[@name='parameterName']" />
											</xsl:element>
											<xsl:element name="field_name">source_service_char_code</xsl:element>
										</xsl:element>
										<xsl:element name="data_type">
											<xsl:value-of select="$dataType"/>
										</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of select="request-param[@name='configuredValue']" />
										</xsl:element>
									</xsl:element>
								</xsl:when>
								<xsl:when test="$dataType = 'LINEOWNER' and request-param[@name='configuredName'] != ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code_ref">
											<xsl:element name="command_id"><xsl:text>get_servicechar_code_</xsl:text>
												<xsl:value-of select="request-param[@name='parameterName']" />
											</xsl:element>
											<xsl:element name="field_name">source_service_char_code</xsl:element>
										</xsl:element>
										<xsl:element name="data_type">
											<xsl:value-of select="$dataType"/>
										</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of select="request-param[@name='configuredName']" />
										</xsl:element>
									</xsl:element>
								</xsl:when>
								<xsl:when test="$dataType = 'ADDRESS' and request-param[@name='configuredCity'] != ''">
									<xsl:element name="CcmFifAddressCharacteristicCont">
										<xsl:element name="service_char_code_ref">
											<xsl:element name="command_id"><xsl:text>get_servicechar_code_</xsl:text>
												<xsl:value-of select="request-param[@name='parameterName']" />
											</xsl:element>
											<xsl:element name="field_name">source_service_char_code</xsl:element>
										</xsl:element>
										<xsl:element name="data_type">
											<xsl:value-of select="$dataType"/>
										</xsl:element>
										<xsl:element name="address_ref">
		        							<xsl:element name="command_id">
												<xsl:text>create_address_</xsl:text>
												<xsl:value-of select="request-param[@name='parameterName']"/>
		       								 </xsl:element>
		        							<xsl:element name="field_name">address_id</xsl:element>
		     							 </xsl:element>
									</xsl:element>
								</xsl:when>
								<xsl:when test="($dataType = 'MAIN_ACCESS_NUM' or $dataType = 'ACC_NUM_RANGE') 
									and request-param[@name='configuredLocalNumber'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code_ref">
											<xsl:element name="command_id"><xsl:text>get_servicechar_code_</xsl:text>
												<xsl:value-of select="request-param[@name='parameterName']" />
											</xsl:element>
											<xsl:element name="field_name">source_service_char_code</xsl:element>
										</xsl:element>
										<xsl:element name="data_type">
											<xsl:value-of select="$dataType"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="request-param[@name='configuredCountryCode']" />
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="request-param[@name='configuredAreaCode']" />
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="request-param[@name='configuredLocalNumber']" />
										</xsl:element>
										<xsl:element name="from_ext_num">
											<xsl:value-of select="request-param[@name='configuredStartNumber']" />
										</xsl:element>
										<xsl:element name="to_ext_num">
											<xsl:value-of select="request-param[@name='configuredEndNumber']" />
										</xsl:element>
									</xsl:element>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</xsl:element>
					<xsl:element name="ignore_empty_csc_id">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create Customer Order for everything -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
							<xsl:value-of select="request-param[@name='OMTSOrderID']" />
						</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
                    <xsl:element name="command_id">reconf_main_service</xsl:element>
                    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- release order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">Release_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
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
			
			<!-- Create Contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">RECONF_FUNCTION</xsl:element>
            <xsl:element name="short_description">Rufnummernänderung</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>Rufnummernänderung für Dienst </xsl:text>
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              <xsl:text> beauftragt. &#xA;TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text> (</xsl:text>
              <xsl:value-of select="request-param[@name='clientName']"/>
              <xsl:text>)</xsl:text>
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
              <xsl:element name="value">ACKNOWLEDGED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
