<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating an customer order by op

  @author Naveen
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
    
<!--
select distinct t.service_char_code, t.datatype_value || t.characteristic_type_value data_type
from service_characteristic t
order by t.service_char_code;
-->
    <xsl:template name="GetDataTypeForCSCCode">
        <xsl:param name="inputCSCCode"/>
        <!--
        <xsl:for-each select="document('CSCDataTypeMap.xml')/ROWDATA/ROW">
            <xsl:if test="SERVICE_CHAR_CODE = $inputCSCCode">
                <xsl:value-of select="DATA_TYPE"/>
            </xsl:if>
        </xsl:for-each>
        -->
        <xsl:value-of select="dateutils:getDataTypeForServiceCharCode($inputCSCCode)"/>
    </xsl:template>
        
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
        <xsl:element name="Command_List">

            <xsl:for-each select="request-param-list[@name='ServiceCharacteristicList;ServiceCharacteristic']/request-param-list-item">
               <xsl:variable name="dataTypeCheck">
                  <xsl:call-template name="GetDataTypeForCSCCode">
                     <xsl:with-param name="inputCSCCode" select="request-param[@name='ServiceCharCode']"/>
                  </xsl:call-template>
               </xsl:variable>

               <xsl:if test="contains($dataTypeCheck, 'NOT_FOUND') or $dataTypeCheck = ''">
				      <xsl:element name="CcmFifRaiseErrorCmd">
					      <xsl:element name="command_id">missingPsmData</xsl:element>
					      <xsl:element name="CcmFifRaiseErrorInCont">
						      <xsl:element name="error_text">
                           <xsl:value-of select="concat('No dataType found for service characteristic code ', request-param[@name='ServiceCharCode'], '. Please check PSM data.')"/>
                        </xsl:element>
					      </xsl:element>
				      </xsl:element>
               </xsl:if>
            </xsl:for-each>

            <xsl:element name="CcmFifGetCustomerOrderDataCmd">
                <xsl:element name="command_id">get_customer_number</xsl:element>
                <xsl:element name="CcmFifGetCustomerOrderDataInCont">
                    <xsl:element name="customer_order_id">
                        <xsl:value-of select="request-param[@name='CustomerOrderID']"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

            <!-- Lock the customer to avoid concurrent updates -->
            <xsl:element name="CcmFifLockObjectCmd">
                <xsl:element name="command_id">lock_customer_order</xsl:element>
                <xsl:element name="CcmFifLockObjectInCont">
                    <xsl:element name="object_id">
                        <xsl:value-of select="request-param[@name='CustomerOrderID']"/>
                    </xsl:element>
                    <xsl:element name="object_type">CUSTOMER_ORDER</xsl:element>
                </xsl:element>
            </xsl:element>

            <!-- Get Entity Information -->   
            <xsl:element name="CcmFifGetEntityCmd">
               <xsl:element name="command_id">get_entity</xsl:element>
               <xsl:element name="CcmFifGetEntityInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">get_customer_number</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>

            <xsl:if test="count(request-param-list[@name='ServiceCharacteristicList;ServiceCharacteristic']/request-param-list-item) != 0">
               <xsl:for-each select="request-param-list[@name='ServiceCharacteristicList;ServiceCharacteristic']/request-param-list-item">

                  <!-- get data type -->
                  <xsl:variable name="dataType">
                     <xsl:call-template name="GetDataTypeForCSCCode">
                        <xsl:with-param name="inputCSCCode" select="request-param[@name='ServiceCharCode']"/>
                     </xsl:call-template>
                  </xsl:variable>

                  <!-- configured values -->
                  <xsl:if test="$dataType = 'ADDRESS'">

                     <xsl:if test="(request-param[@name='Address;StreetName'] != ''
                                        and request-param[@name='Address;StreetNumber'] != ''
                                        or request-param[@name='Address;PostOfficeBox'] != '')
                                   and request-param[@name='Address;PostalCode'] != ''
                                   and request-param[@name='Address;CityName'] != ''">
                       <!-- Create Address-->
                       <xsl:element name="CcmFifCreateAddressCmd">
                        <xsl:element name="command_id">
                          <xsl:text>create_address_</xsl:text>
                          <xsl:value-of select="concat(request-param[@name='ServiceSubscriptionId'],request-param[@name='ServiceCharCode'])"/>
                        </xsl:element>
                        <xsl:element name="CcmFifCreateAddressInCont">
                          <xsl:element name="entity_ref">
                           <xsl:element name="command_id">get_entity</xsl:element>
                           <xsl:element name="field_name">entity_id</xsl:element>
                          </xsl:element>
                          <xsl:if test="request-param[@name='Address;AddressType'] != ''">
                             <xsl:element name="address_type">
                                 <xsl:value-of select="request-param[@name='Address;AddressType']"/>
                             </xsl:element>
                          </xsl:if>
                          <xsl:if test="request-param[@name='Address;AddressType'] = ''">
                             <xsl:element name="address_type">LOKA</xsl:element>
                          </xsl:if>
                          <xsl:choose>
                             <xsl:when test="request-param[@name='Address;StreetName'] != '' and request-param[@name='Address;StreetNumber'] != ''">
                                <xsl:element name="street_name">
                                   <xsl:value-of select="request-param[@name='Address;StreetName']"/>
                                </xsl:element>
                                <xsl:element name="street_number">
                                   <xsl:value-of select="request-param[@name='Address;StreetNumber']"/>
                                </xsl:element>
                                <xsl:element name="street_number_suffix">
                                   <xsl:value-of select="request-param[@name='Address;StreetNumberSuffix']"/>
                                </xsl:element>
                            </xsl:when>
                             <xsl:when test="request-param[@name='Address;PostOfficeBox'] != ''">
                                <xsl:element name="post_office_box">
                                   <xsl:value-of select="request-param[@name='Address;PostOfficeBox']"/>
                                </xsl:element>
                             </xsl:when>
                          </xsl:choose>
                          <xsl:element name="postal_code">
                              <xsl:value-of select="request-param[@name='Address;PostalCode']"/>
                          </xsl:element>
                          <xsl:element name="city_name">
                              <xsl:value-of select="request-param[@name='Address;CityName']"/>
                          </xsl:element>
                          <xsl:element name="city_suffix_name">
                              <xsl:value-of select="request-param[@name='Address;CitySuffixName']"/>
                          </xsl:element>
                          <xsl:if test="request-param[@name='Address;Country'] != ''">
                             <xsl:element name="country_code">
                                 <xsl:value-of select="request-param[@name='Address;Country']"/>
                             </xsl:element>
                          </xsl:if>
                          <xsl:if test="request-param[@name='Address;Country'] = ''">
                             <xsl:element name="country_code">DE</xsl:element>
                          </xsl:if>
                          <xsl:element name="address_additional_text">
                              <xsl:value-of select="request-param[@name='Address;AdditionalAddressDescription']"/>
                          </xsl:element>
                          <xsl:element name="set_primary_address">N</xsl:element>
                          <xsl:element name="ignore_existing_address">Y</xsl:element>
                        </xsl:element>
                       </xsl:element>
                     </xsl:if>

                     <xsl:if test="not ((request-param[@name='Address;StreetName'] != ''
                                        and request-param[@name='Address;StreetNumber'] != ''
                                        or request-param[@name='Address;PostOfficeBox'] != '')
                                   and request-param[@name='Address;PostalCode'] != ''
                                   and request-param[@name='Address;CityName'] != '')">
				            <xsl:element name="CcmFifRaiseErrorCmd">
					            <xsl:element name="command_id">incompleteAddressData</xsl:element>
					            <xsl:element name="CcmFifRaiseErrorInCont">
						            <xsl:element name="error_text">
                                 <xsl:value-of select="concat('Incomplete address data for ', request-param[@name='ServiceSubscriptionId'], ' ', request-param[@name='ServiceCharCode'], '. Address update will be skipped.')"/>
                              </xsl:element>
                              <xsl:element name="log_warning">Y</xsl:element>
					            </xsl:element>
				            </xsl:element>
                     </xsl:if>

                  </xsl:if>

               </xsl:for-each>
            </xsl:if>


            <xsl:element name="CcmFifCompleteCustomerOrderCmd">
                <xsl:element name="command_id">customer_order_activation</xsl:element>
                <xsl:element name="CcmFifCompleteCustomerOrderInCont">
                    <xsl:element name="customer_order_id">
                        <xsl:value-of select="request-param[@name='CustomerOrderID']"/>
                    </xsl:element>
                    <xsl:element name="activate_customer_order">
                        <xsl:if test="request-param[@name='ActivateCustomerOrder'] = 'true'">
                            <xsl:text>Y</xsl:text>
                        </xsl:if>
                        <xsl:if test="request-param[@name='ActivateCustomerOrder'] = 'false'">
                            <xsl:text>N</xsl:text>
                        </xsl:if>
                    </xsl:element>
                    <xsl:if test="count(request-param-list[@name='ServiceCharacteristicList;ServiceCharacteristic']/request-param-list-item) != 0">
                        <xsl:element name="service_characteristic_list">

                        <xsl:for-each select="request-param-list[@name='ServiceCharacteristicList;ServiceCharacteristic']/request-param-list-item">

                            <!-- get data type -->
                            <xsl:variable name="dataType">
                                <xsl:call-template name="GetDataTypeForCSCCode">
                                    <xsl:with-param name="inputCSCCode" select="request-param[@name='ServiceCharCode']"/>
                                </xsl:call-template>
                            </xsl:variable>

                            <!-- Access Number -->
                            <!-- <xsl:if test="count(request-param[starts-with(@name,'SingleNumber')])>0"> -->
                            <xsl:if test="$dataType = 'MAIN_ACCESS_NUM'
                                          or $dataType = 'MOBIL_ACCESS_NUM'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">
                                        <xsl:value-of select="$dataType"/>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                    <xsl:element name="country_code">
                                        <xsl:value-of select="request-param[@name='SingleNumber;CountryCode']"/>
                                    </xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="request-param[@name='SingleNumber;LocalAreaCode']"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="request-param[@name='SingleNumber;PilotNumber']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>

                            <xsl:if test="$dataType = 'ACC_NUM_RANGE'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">
                                        <xsl:value-of select="$dataType"/>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                    <xsl:element name="country_code">
                                        <xsl:value-of select="request-param[@name='AccessNumberRange;CountryCode']"/>
                                    </xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="request-param[@name='AccessNumberRange;LocalAreaCode']"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="request-param[@name='AccessNumberRange;PilotNumber']"/>
                                    </xsl:element>
                                    <xsl:element name="from_ext_num">
                                        <xsl:value-of select="request-param[@name='AccessNumberRange;BeginRange']"/>
                                    </xsl:element>
                                    <xsl:element name="to_ext_num">
                                        <xsl:value-of select="request-param[@name='AccessNumberRange;EndRange']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>

                            <xsl:if test="$dataType = 'IP_NET_ADDRESS'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">
                                        <xsl:value-of select="$dataType"/>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                    <xsl:element name="ip_number">
                                        <xsl:value-of select="request-param[@name='IpNetAddress;IpNumber']"/>
                                    </xsl:element>
                                    <xsl:element name="subnet_mask">
                                        <xsl:value-of select="request-param[@name='IpNetAddress;SubnetMask']"/>
                                    </xsl:element>
                                    <xsl:element name="alias">
                                        <xsl:value-of select="request-param[@name='IpNetAddress;Alias']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>

                            <xsl:if test="$dataType = 'TECH_SERVICE_ID'
                                          or $dataType = 'USER_ACCOUNT_NUM'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">
                                        <xsl:value-of select="$dataType"/>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                    <xsl:element name="network_account">
                                        <xsl:if test="$dataType = 'TECH_SERVICE_ID'">
                                           <xsl:value-of select="request-param[@name='TechnicalServiceId']"/>
                                        </xsl:if>
                                        <xsl:if test="$dataType = 'USER_ACCOUNT_NUM'">
                                           <xsl:value-of select="request-param[@name='NetworkAccount']"/>
                                        </xsl:if>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>

                            <xsl:if test="$dataType = 'SERVICE_LOCATION'">
                                <xsl:element name="CcmFifServiceLocationCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                    <xsl:element name="floor">
                                        <xsl:value-of select="request-param[@name='ServiceLocation;Floor']"/>
                                    </xsl:element>
                                    <xsl:element name="room_number">
                                        <xsl:value-of select="request-param[@name='ServiceLocation;RoomNumber']"/>
                                    </xsl:element>
                                    <xsl:element name="jack_location">
                                        <xsl:value-of select="request-param[@name='ServiceLocation;JackLocation']"/>
                                    </xsl:element>
                                    <xsl:element name="desk_number">
                                        <xsl:value-of select="request-param[@name='ServiceLocation;DeskNumber']"/>
                                    </xsl:element>
                                    <xsl:element name="additional_location_info">
                                        <xsl:value-of select="request-param[@name='ServiceLocation;AdditionalLocationInfo']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>

                            <!-- configured values -->
                            <xsl:if test="$dataType = 'DIRECTORY_ENTRY'">
                                <xsl:element name="CcmFifConfiguredValueCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">
                                        <xsl:value-of select="$dataType"/>
                                    </xsl:element>
                                    <xsl:element name="configured_value">
                                           <xsl:value-of select="request-param[contains(@name,'StringValue')]"/>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>

                            <xsl:if test="$dataType = 'BOOLEAN'
                                                or $dataType = 'DATE'
                                                or $dataType = 'DECIMAL'
                                                or $dataType = 'INTEGER'
                                                or $dataType = 'STRING'">
                                <xsl:element name="CcmFifConfiguredValueCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">
                                        <xsl:value-of select="$dataType"/>
                                    </xsl:element>
                                    <xsl:element name="configured_value">
                                        <!--<xsl:value-of select="request-param[contains(@name,'Value')]"/>-->
                                        <xsl:if test="$dataType = 'BOOLEAN'">
                                            <xsl:value-of select="request-param[contains(@name,'BooleanValue')]"/>
                                        </xsl:if>
                                        <xsl:if test="$dataType = 'DATE'
                                                      and request-param[contains(@name,'DateValue')] != ''">
                                           <xsl:value-of select="dateutils:createOPMDate(request-param[contains(@name,'DateValue')])"/>
                                           <xsl:value-of select="dateutils:SOM2OPMDate(request-param[contains(@name,'DateValue')])"/>
                                        </xsl:if>
                                        <xsl:if test="$dataType = 'DECIMAL'">
                                            <xsl:value-of select="request-param[contains(@name,'DecimalValue')]"/>
                                        </xsl:if>
                                        <xsl:if test="$dataType = 'INTEGER'">
                                            <xsl:value-of select="request-param[contains(@name,'IntegerValue')]"/>
                                        </xsl:if>
                                        <xsl:if test="$dataType = 'STRING'">
                                            <xsl:value-of select="request-param[contains(@name,'StringValue')]"/>
                                        </xsl:if>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                            
                            <!-- address -->
                            <xsl:if test="$dataType = 'ADDRESS' 
                                          and (request-param[@name='Address;StreetName'] != ''
                                               and request-param[@name='Address;StreetNumber'] != ''
                                               or request-param[@name='Address;PostOfficeBox'] != '')
                                          and request-param[@name='Address;PostalCode'] != ''
                                          and request-param[@name='Address;CityName'] != ''">
                                <xsl:element name="CcmFifAddressCharacteristicCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of select="request-param[@name='ServiceCharCode']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">ADDRESS</xsl:element>
                                    <xsl:element name="address_ref">
                                        <xsl:element name="command_id">
                                            <xsl:text>create_address_</xsl:text>
                                            <xsl:value-of select="concat(request-param[@name='ServiceSubscriptionId'],request-param[@name='ServiceCharCode'])"/>
                                        </xsl:element>
                                        <xsl:element name="field_name">address_id</xsl:element>
                                    </xsl:element>
                                    <xsl:element name="service_subscription_id">
                                        <xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
                                    </xsl:element>
                                </xsl:element>                  
                            </xsl:if>
                            
                        </xsl:for-each>

                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:element>

			   <!-- add com barcode reference on customer order -->
            <xsl:if test="request-param[@name='orderId'] != ''">
			      <xsl:element name="CcmFifAddCcmParameterMapCmd">
				      <xsl:element name="CcmFifAddCcmParameterMapInCont">
					      <xsl:element name="supported_object_id">
                        <xsl:value-of select="request-param[@name='CustomerOrderID']"/>
					      </xsl:element>
					      <xsl:element name="supported_object_type_rd">CUST_ORDER</xsl:element>
					      <xsl:element name="param_name_rd">ORDERID_COM_NOTI</xsl:element>
					      <xsl:element name="param_value">
                        <xsl:value-of select="request-param[@name='orderId']"/>
					      </xsl:element>
				      </xsl:element>
			      </xsl:element>	
            </xsl:if>

            <!-- Create Contact -->
            <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:element name="customer_number_ref">
                        <xsl:element name="command_id">get_customer_number</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                    </xsl:element>
                    <xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
                    <xsl:element name="short_description">Kundenauftrag aktiviert</xsl:element>
                    <xsl:element name="long_description_text">
                        <xsl:text>Der Kundenauftrag wurde über BUS (ActivateCustomerOrder)</xsl:text>
                        <xsl:if test="request-param[@name='ActivateCustomerOrder'] = 'true'">
                            <xsl:text> aktiviert</xsl:text>
                        </xsl:if>
                        <xsl:if test="request-param[@name='ActivateCustomerOrder'] != 'true'">
                            <xsl:text> umkonfiguriert</xsl:text>
                        </xsl:if>
                        <xsl:text> (SBUS-TransactionID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text>). Kundenauftrag: </xsl:text>
                        <xsl:value-of select="request-param[@name='CustomerOrderID']"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
    
