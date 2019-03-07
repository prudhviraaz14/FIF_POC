<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding additional services.
  @author banania
-->
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

      <xsl:variable name="MaskingDigits">
        <xsl:choose>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">0</xsl:when>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">20</xsl:when>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">-1</xsl:when>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">-1</xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>

      </xsl:variable>

      <xsl:variable name="StorageMaskingDigits">
        <xsl:choose>
          <xsl:when test="request-param[@name='cdrStorageFormat'] = 'IMMEDIATE_DELETION'">0</xsl:when>
          <xsl:when test="request-param[@name='cdrStorageFormat'] = 'ABBREVIATED_STORAGE'">20</xsl:when>
          <xsl:when test="request-param[@name='cdrStorageFormat'] = 'FULL_STORAGE'">-1</xsl:when>
          <xsl:when test="request-param[@name='cdrStorageFormat'] = 'NORMAL_STORAGE'">-1</xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="RetentionPeriod">
        <xsl:choose>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">80NODT</xsl:when>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">80DETL</xsl:when>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">80DETL</xsl:when>
          <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">80DETL</xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$MaskingDigits = 'unknown'
        or $StorageMaskingDigits = 'unknown'
        or $RetentionPeriod = 'unknown'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error_unknown_value</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Unbekannter Wert für EGN gewaehlt.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:variable name="Type">
        <!-- the empty text in each variable is a hack to have the variable existing
          even if the original is not defined in one of the FIF clients -->
        <xsl:text/>
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable>

      <xsl:variable name="desiredDate" select="request-param[@name='desiredDate']"/>
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
        
      <xsl:variable name="additionalServiceType" select="request-param[@name='additionalServiceType']"/>
      <xsl:variable name="useAdditionalServiceType" select="request-param[@name='useAdditionalServiceType']"/>
        
      <xsl:variable name="addChildService">
        <xsl:choose>
          <xsl:when test="$Type != '' or $useAdditionalServiceType != ''">Y</xsl:when>
            <xsl:otherwise>N</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
        
      <xsl:variable name="serviceSubscriptionId">
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable>

      <xsl:variable name="productSubscriptionId">
        <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
      </xsl:variable>

      <xsl:variable name="requestListId">
        <xsl:text/>
          <xsl:value-of select="request-param[@name='requestListId']"/>
      </xsl:variable>


        <!-- Get Customer number if not provided-->
        <xsl:if test="(request-param[@name='customerNumber'] = '')">
            <xsl:element name="CcmFifReadExternalNotificationCmd">
                <xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
                <xsl:element name="CcmFifReadExternalNotificationInCont">
                    <xsl:element name="transaction_id">
                        <xsl:value-of select="$requestListId"/>
                    </xsl:element>
                    <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
      <!-- Get product subscription if not provided-->
      <xsl:if test="$productSubscriptionId = ''">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_prod_subs_from_ext_noti</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="$requestListId"/>
            </xsl:element>
            <xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
        <!-- Get Account number if not provided -->
        <xsl:if test="(request-param[@name='accountNumber'] = '')">
            <xsl:element name="CcmFifReadExternalNotificationCmd">
                <xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
                <xsl:element name="CcmFifReadExternalNotificationInCont">
                    <xsl:element name="transaction_id">
                        <xsl:value-of select="$requestListId"/>
                    </xsl:element>
                    <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        
      <!-- Validate the parameter type -->
      <xsl:if test="$Type != ''
        and $serviceSubscriptionId != ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter 'type' can be set only if the main access service can not be determined!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Validate the parameter type -->
      <xsl:if test="$Type != ''
        and $useAdditionalServiceType != ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Either 'type' or 'useAdditionalServiceType' can be set. The Setting of both parameters is not allowed!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <!-- Find the main Service  by Service Subscription Id-->
      <xsl:if test="$serviceSubscriptionId != '' ">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="$serviceSubscriptionId"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Take value of serviceSubscriptionId from ccm external notification if serviceSubscriptionId not provided -->
      <xsl:if test="$Type != '' or $useAdditionalServiceType != ''">

         <xsl:if test="$Type != ''">
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_service_subscription</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="$requestListId"/>
              </xsl:element>
              <xsl:element name="parameter_name">
                <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
          
          <xsl:if test="$useAdditionalServiceType != ''">
          <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_service_subscription</xsl:element>
              <xsl:element name="CcmFifReadExternalNotificationInCont">
                  <xsl:element name="transaction_id">
                      <xsl:value-of select="$requestListId"/>
                  </xsl:element>
                  <xsl:element name="parameter_name">
                    <xsl:value-of select="concat($useAdditionalServiceType, '_SERVICE_SUBSCRIPTION_ID')"/>
                  </xsl:element>
              </xsl:element>
          </xsl:element>
          </xsl:if>
          
 
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_service_subscription</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
        
      <xsl:if test="$Type = ''and 
          $useAdditionalServiceType = ''">
          <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">						                  
                  <xsl:element name="product_subscription_id_ref">
                      <xsl:element name="command_id">read_prod_subs_from_ext_noti</xsl:element>
                      <xsl:element name="field_name">parameter_value</xsl:element>
                  </xsl:element>
                  <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
              </xsl:element>
          </xsl:element>                          
      </xsl:if>

      <!-- Create Address if not provided -->
      <xsl:if test="request-param[@name='addressId'] = ''
        and request-param[@name='createAddress'] = 'Y'">
        <!-- Get Entity Information -->
        <xsl:element name="CcmFifGetEntityCmd">
          <xsl:element name="command_id">get_entity_1</xsl:element>
          <xsl:element name="CcmFifGetEntityInCont">
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
          </xsl:element>
        </xsl:element>
        <!-- Create Address-->
        <xsl:element name="CcmFifCreateAddressCmd">
          <xsl:element name="command_id">create_address</xsl:element>
          <xsl:element name="CcmFifCreateAddressInCont">
            <xsl:element name="entity_ref">
              <xsl:element name="command_id">get_entity_1</xsl:element>
              <xsl:element name="field_name">entity_id</xsl:element>
            </xsl:element>
            <xsl:element name="address_type">STD</xsl:element>
            <xsl:element name="street_name">
              <xsl:value-of select="request-param[@name='streetName']"/>
            </xsl:element>
            <xsl:element name="street_number">
              <xsl:value-of select="request-param[@name='streetNumber']"/>
            </xsl:element>
            <xsl:element name="street_number_suffix">
              <xsl:value-of select="request-param[@name='numberSuffix']"/>
            </xsl:element>
            <xsl:element name="postal_code">
              <xsl:value-of select="request-param[@name='postalCode']"/>
            </xsl:element>
            <xsl:element name="city_name">
              <xsl:value-of select="request-param[@name='city']"/>
            </xsl:element>
            <xsl:element name="city_suffix_name">
              <xsl:value-of select="request-param[@name='citySuffix']"/>
            </xsl:element>
            <xsl:if test="request-param[@name='country']!=''">
              <xsl:element name="country_code">
                <xsl:value-of select="request-param[@name='country']"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='country']=''">
              <xsl:element name="country_code">DE</xsl:element>
            </xsl:if>
            <xsl:element name="address_additional_text">
              <xsl:value-of select="request-param[@name='additionalText']"/>
            </xsl:element>
            <xsl:element name="set_primary_address">N</xsl:element>
            <xsl:element name="ignore_existing_address">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Add Main Service Subscription  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_additional_service</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="$productSubscriptionId = ''">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">read_prod_subs_from_ext_noti</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="$productSubscriptionId != ''">
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="$productSubscriptionId"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='serviceCode']"/>
          </xsl:element>
          <xsl:if test="$addChildService= 'Y'">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:value-of select="$desiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='reasonRd']"/>
          </xsl:element>
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
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='configServiceCharList']/request-param-list-item">
              <!-- address characteristic -->
              <xsl:if test="request-param[@name='dataType'] = 'ADDRESS'">

                <xsl:variable name="addressId">
                  <xsl:text/>
                  <xsl:value-of select="../request-param[@name='addressId']"/>
                </xsl:variable>

                <xsl:element name="CcmFifAddressCharacteristicCont">
                  <xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
                  <xsl:element name="data_type">ADDRESS</xsl:element>
                  <xsl:if test="$addressId = ''">
                    <xsl:element name="address_ref">
                      <xsl:element name="command_id">create_address</xsl:element>
                      <xsl:element name="field_name">address_id</xsl:element>
                    </xsl:element>
                  </xsl:if>
                  <xsl:if test="$addressId != ''">
                    <xsl:element name="address_id">
                      <xsl:value-of select="$addressId"/>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:if>
              <!-- configured value characteristic -->
              <xsl:if test="(request-param[@name='dataType'] = 'BOOLEAN' or request-param[@name='dataType'] = 'DATE' or
                request-param[@name='dataType'] = 'DECIMAL' or request-param[@name='dataType'] = 'INTEGER' or
                request-param[@name='dataType'] = 'PIN_NUMBER' or request-param[@name='dataType'] = 'STRING' or
                request-param[@name='dataType'] = 'TIME')">
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
                  <xsl:element name="data_type"><xsl:value-of select="request-param[@name='dataType']"/></xsl:element>
                  <xsl:element name="configured_value"><xsl:value-of select="request-param[@name='configuredValue']"/></xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- User Account ID -->
              <xsl:if test="request-param[@name='dataType'] = 'USER_ACCOUNT_NUM'">
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
                  <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
                  <xsl:element name="masking_digits_rd"><xsl:value-of select="$MaskingDigits"/></xsl:element>
                  <xsl:element name="retention_period_rd"><xsl:value-of select="$RetentionPeriod"/></xsl:element>
                  <xsl:element name="storage_masking_digits_rd"><xsl:value-of select="$StorageMaskingDigits"/></xsl:element>
                  <xsl:element name="network_account"><xsl:value-of select="request-param[@name='userAccountId']"/></xsl:element>
                </xsl:element>
              </xsl:if>

              <!-- service location characteristic -->
              <xsl:if test="request-param[@name='dataType'] = 'SERVICE_LOCATION'">
                <xsl:element name="CcmFifServiceLocationCont">
                  <xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
                  <xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
                  <xsl:element name="jack_location">
                    <xsl:value-of select="request-param[@name='serviceLocation']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    
        <xsl:if test="request-param[@name='pricePlanOptionValue'] != ''">
          <!-- Configure Price Plan -->
          <xsl:element name="CcmFifConfigurePPSCmd">
            <xsl:element name="command_id">config_pps_1</xsl:element>
            <xsl:element name="CcmFifConfigurePPSInCont">
                <xsl:element name="product_subscription_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="price_plan_code">
                    <xsl:value-of select="request-param[@name='pricePlanCode']"/>
                </xsl:element>	                
                <xsl:element name="effective_date">
                    <xsl:value-of select="$desiredDate"/>
                </xsl:element>					
                <xsl:element name="pps_option_value">
                    <xsl:value-of select="request-param[@name='pricePlanOptionValue']"/>
                </xsl:element>
            </xsl:element>
          </xsl:element>
      </xsl:if>

      <!-- find an open customer order for the main service -->
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_customer_order_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="state_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">ASSIGNED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="allow_children">Y</xsl:element>
          <xsl:element name="usage_mode">1</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add STPs to customer order if exists -->
      <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
        <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_additional_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for condition Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
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
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_additional_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!--Release customer order for the condition services -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
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
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the addition of the condition services -->
      <xsl:element name="CcmFifCreateContactCmd">
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
          <xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Service Code: </xsl:text>
            <xsl:value-of select="request-param[@name='serviceCode']"/>
               <xsl:text>&#xA;Desired Date: </xsl:text>
              <xsl:value-of select="$desiredDate"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

        <!--  Create  external notification if the requestListId is set  -->
        <xsl:if test="$additionalServiceType != ''">
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <xsl:element name="command_id">create_notification_1</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                    <xsl:element name="effective_date">
                        <xsl:value-of select="$desiredDate"/>
                    </xsl:element>
                    <xsl:element name="transaction_id">
                        <xsl:value-of select="$requestListId"/>
                    </xsl:element>
                    <xsl:element name="processed_indicator">Y</xsl:element>
                    <xsl:element name="notification_action_name">AddAdditionalServiceSubscription</xsl:element>
                    <xsl:element name="target_system">FIF</xsl:element>
                    <xsl:element name="parameter_value_list">
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">
                                <xsl:value-of select="concat($additionalServiceType, '_SERVICE_SUBSCRIPTION_ID')"/>
                            </xsl:element>
                            <xsl:element name="parameter_value_ref">
                                <xsl:element name="command_id">add_additional_service</xsl:element>
                                <xsl:element name="field_name">service_subscription_id</xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

