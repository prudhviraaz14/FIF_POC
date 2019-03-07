<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
   xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
   <!--
      XSLT file for creating a FIF request for Adding Hardware Service
      @author schwarje 
   -->
   <xsl:template match="/">
      <xsl:element name="CcmFifCommandList">
         <xsl:apply-templates select="request/request-params"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="request-params">
      <!-- Copy over transaction ID, client name, override system date and action name -->
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
         <xsl:variable name="Type" select="request-param[@name='type']"/>

         <!-- Validate the zero charge indicator -->
         <xsl:if
            test="request-param[@name='zeroChargeIndicator'] != ''
			and request-param[@name='zeroChargeIndicator'] != 'JA'
			and request-param[@name='zeroChargeIndicator'] != 'NEIN'">
            <xsl:element name="CcmFifRaiseErrorCmd">
               <xsl:element name="command_id">zerocharge_error</xsl:element>
               <xsl:element name="CcmFifRaiseErrorInCont">
                  <xsl:element name="error_text">The parameter zeroChargeIndicator has to be set to
                     JA or NEIN!</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:if>


         <!-- get the next available PTN for the OMTSOrderID -->
         <xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberCmd">
            <xsl:element name="command_id">get_ptn</xsl:element>
            <xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberInCont">
               <xsl:element name="customer_tracking_id">
                  <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Find Service Subscription -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''">
            <!-- Get Entity Information -->
            <xsl:element name="CcmFifGetEntityCmd">
               <xsl:element name="command_id">get_entity_1</xsl:element>
               <xsl:element name="CcmFifGetEntityInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <!--Create new hardware address-->
            <xsl:element name="CcmFifCreateAddressCmd">
               <xsl:element name="command_id">create_addr_1</xsl:element>
               <xsl:element name="CcmFifCreateAddressInCont">
                  <xsl:element name="entity_ref">
                     <xsl:element name="command_id">get_entity_1</xsl:element>
                     <xsl:element name="field_name">entity_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="address_type">LOKA</xsl:element>
                  <xsl:element name="street_name">
                     <xsl:value-of select="request-param[@name='hardwareDeliveryStreet']"/>
                  </xsl:element>
                  <xsl:element name="street_number">
                     <xsl:value-of select="request-param[@name='hardwareDeliveryNumber']"/>
                  </xsl:element>
                  <xsl:element name="street_number_suffix">
                     <xsl:value-of select="request-param[@name='hardwareDeliveryNumberSuffix']"/>
                  </xsl:element>
                  <xsl:element name="postal_code">
                     <xsl:value-of select="request-param[@name='hardwareDeliveryPostalCode']"/>
                  </xsl:element>
                  <xsl:element name="city_name">
                     <xsl:value-of select="request-param[@name='hardwareDeliveryCity']"/>
                  </xsl:element>
                  <xsl:element name="city_suffix_name">
                     <xsl:value-of select="request-param[@name='hardwareDeliveryCitySuffix']"/>
                  </xsl:element>
                  <xsl:element name="country_code">DE</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:if>

         <!-- Check customer classification -->
         <xsl:element name="CcmFifGetCustomerDataCmd">
            <xsl:element name="command_id">get_customer_data</xsl:element>
            <xsl:element name="CcmFifGetCustomerDataInCont">
               <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Concat the result of recent command to create promary value of cross reference  -->
         <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">concat_primary_value</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
               <xsl:element name="input_string_list">
                  <xsl:element name="CcmFifPassingValueCont">
                     <xsl:element name="value">V0088_</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">get_customer_data</xsl:element>
                     <xsl:element name="field_name">classification_rd</xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Get service code value for given customer classification from reference data -->
         <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
            <xsl:element name="command_id">get_cross_ref_data</xsl:element>
            <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
               <xsl:element name="group_code">SCCLASSDEF</xsl:element>
               <xsl:element name="primary_value_ref">
                  <xsl:element name="command_id">concat_primary_value</xsl:element>
                  <xsl:element name="field_name">output_string</xsl:element>
               </xsl:element>
               <xsl:element name="ignore_empty_result">Y</xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Add hardware Service -->
         <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
               <xsl:element name="product_subscription_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
               </xsl:element>
               <xsl:if
                  test="(request-param[@name='addIADHardwareService']!='Y') 
					and (request-param[@name='hardwareServiceCode'] = '')">
                  <xsl:element name="service_code">V0114</xsl:element>
               </xsl:if>
               <xsl:if
                  test="(request-param[@name='addIADHardwareService']='Y') 
					and (request-param[@name='hardwareServiceCode'] = '')">
                  <xsl:element name="service_code">V011A</xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="(request-param[@name='hardwareServiceCode']!= '') ">
                  <xsl:element name="service_code">
                     <xsl:value-of select="request-param[@name='hardwareServiceCode']"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if
                  test="(request-param[@name='hardwareServiceCode']!= '') 
					and (request-param[@name='hardwareServiceCode']!= 'V0114')
					and (request-param[@name='hardwareServiceCode']!= 'I1350')">
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
               </xsl:if>
               <xsl:element name="desired_schedule_type">ASAP</xsl:element>
               <xsl:element name="reason_rd">AEND</xsl:element>
               <xsl:element name="account_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">account_number</xsl:element>
               </xsl:element>
               <xsl:element name="service_characteristic_list">
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0110</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='hardwareDeliverySalutation']"/>
                        <xsl:text>;</xsl:text>
                        <xsl:value-of select="request-param[@name='hardwareDeliverySurname']"/>
                        <xsl:text>;</xsl:text>
                        <xsl:value-of select="request-param[@name='hardwareDeliveryForename']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- Lieferanschrift -->
                  <xsl:element name="CcmFifAddressCharacteristicCont">
                     <xsl:element name="service_char_code">V0111</xsl:element>
                     <xsl:element name="data_type">ADDRESS</xsl:element>
                     <xsl:if test="request-param[@name='hardwareDeliveryAddressID'] !=''">
                        <xsl:element name="address_id">
                           <xsl:value-of select="request-param[@name='hardwareDeliveryAddressID']"/>
                        </xsl:element>
                     </xsl:if>
                     <xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''">
                        <xsl:element name="address_ref">
                           <xsl:element name="command_id">create_addr_1</xsl:element>
                           <xsl:element name="field_name">address_id</xsl:element>
                        </xsl:element>
                     </xsl:if>
                  </xsl:element>
                  <!-- Artikelnumber -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0112</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='articleNumber']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- Subventionierungskennzeichen -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0114</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='subventionIndicator']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- Artikelbezeichnung -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0116</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='articleName']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- Zahlungsoption -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0119</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='shippingCosts']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- Bestellgrund -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0989</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='orderReason']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- VO-Nummer -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0990</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
                     </xsl:element>
                  </xsl:element>
                  <!-- Service Provider -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0088</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value_ref">
                        <xsl:element name="command_id">get_cross_ref_data</xsl:element>
                        <xsl:element name="field_name">secondary_value</xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <!-- zeroPrice -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0184</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='zeroChargeIndicator']"/>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="sub_order_id">
                  <xsl:value-of select="request-param[@name='subOrderId']"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- find an open customer order for the main service -->
         <xsl:element name="CcmFifFindCustomerOrderCmd">
            <xsl:element name="command_id">find_customer_order_2</xsl:element>
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
               <xsl:element name="usage_mode">2</xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Add STPs to customer order if exists -->
         <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
            <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
               <xsl:element name="customer_order_id_ref">
                  <xsl:element name="command_id">find_customer_order_2</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
               </xsl:element>
               <xsl:element name="service_ticket_pos_list">
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_1</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_customer_order_2</xsl:element>
                  <xsl:element name="field_name">customer_order_found</xsl:element>
               </xsl:element>
               <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
         </xsl:element>
         <!-- Create stand alone Customer Order for new service  -->
         <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
               <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="cust_order_description">Add hardware service</xsl:element>
               <xsl:element name="customer_tracking_id">
                  <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
               </xsl:element>
               <xsl:element name="provider_tracking_no_ref">
                  <xsl:element name="command_id">get_ptn</xsl:element>
                  <xsl:element name="field_name">provider_tracking_number</xsl:element>
               </xsl:element>
               <xsl:element name="service_ticket_pos_list">
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_1</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_customer_order_2</xsl:element>
                  <xsl:element name="field_name">customer_order_found</xsl:element>
               </xsl:element>
               <xsl:element name="required_process_ind">N</xsl:element>
            </xsl:element>
         </xsl:element>

         <!--Release customer order for hardware service-->
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
               <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_customer_order_2</xsl:element>
                  <xsl:element name="field_name">customer_order_found</xsl:element>
               </xsl:element>
               <xsl:element name="required_process_ind">N</xsl:element>
            </xsl:element>
         </xsl:element>

         <xsl:variable name="contactText">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Hardware Service Code: </xsl:text>
            <xsl:if
               test="request-param[@name='addIADHardwareService']!='Y'
               and request-param[@name='hardwareServiceCode'] = ''">
               <xsl:text>V0114</xsl:text>
            </xsl:if>
            <xsl:if
               test="request-param[@name='addIADHardwareService']='Y'
               and request-param[@name='hardwareServiceCode'] = ''">
               <xsl:text>V011A</xsl:text>
            </xsl:if>
            <xsl:if test="request-param[@name='hardwareServiceCode']!=''">
               <xsl:value-of select="request-param[@name='hardwareServiceCode']"/>
            </xsl:if>
            <xsl:text>&#xA;Desired Date: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>            
         </xsl:variable>


         <!-- Create Contact for hardware Service Addition -->
         <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="CcmFifCreateContactInCont">
               <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="contact_type_rd">ADD_HARDWARE</xsl:element>
               <xsl:element name="short_description">
                  <xsl:text>Dienst hinzugefügt über </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
               </xsl:element>
               <xsl:element name="long_description_text">
                  <xsl:value-of select="$contactText"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Create external notification -->
         <xsl:element name="CcmFifCreateExternalNotificationCmd">
            <xsl:element name="command_id">create_external_notification_1</xsl:element>
            <xsl:element name="CcmFifCreateExternalNotificationInCont">
               <xsl:element name="notification_action_name">createKBANotification</xsl:element>
               <xsl:element name="target_system">KBA</xsl:element>                           				
               <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>											
                     <xsl:element name="parameter_value_ref">
                        <xsl:element name="command_id">find_service_1</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">TYPE</xsl:element>
                     <xsl:element name="parameter_value">CONTACT</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">CATEGORY</xsl:element>
                     <xsl:element name="parameter_value">Migration</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">USER_NAME</xsl:element>
                     <xsl:element name="parameter_value">WOE-SLS</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                     <xsl:element name="parameter_value">CCB</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                     <xsl:element name="parameter_value">								
                        <xsl:value-of select="request-param[@name='desiredDate']"/>														
                     </xsl:element>
                  </xsl:element>					
                  <xsl:element name="CcmFifParameterValueCont">
                     <xsl:element name="parameter_name">TEXT</xsl:element>
                     <xsl:element name="parameter_value">
                        <xsl:value-of select="$contactText"/>
                     </xsl:element>
                  </xsl:element>					
               </xsl:element>
            </xsl:element>
         </xsl:element>
         
         <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

         <xsl:if
            test="(
			request-param[@name='articleNumber'] = '20080360'
			or request-param[@name='articleNumber'] = '20080360'
			or request-param[@name='articleNumber'] = '20080396'
			or request-param[@name='articleNumber'] = '20080397'
			or request-param[@name='articleNumber'] = '20080398'
			or request-param[@name='articleNumber'] = '20080399'
			or request-param[@name='articleNumber'] = '20080400'
			or request-param[@name='articleNumber'] = '20080401')
			and
			(dateutils:compareString(request-param[@name='orderDate'], '2008.03.31 00:00:00') = '1' and
		     dateutils:compareString(request-param[@name='orderDate'], '2008.05.01 00:00:00') = '-1')">

            <!-- lock customer to avoid concurrency problems -->
            <xsl:element name="CcmFifLockObjectCmd">
               <xsl:element name="CcmFifLockObjectInCont">
                  <xsl:element name="object_id_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="object_type">CUSTOMER</xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- construct the four transaction ids -->
            <xsl:element name="CcmFifConcatStringsCmd">
               <xsl:element name="command_id">concat_transaction_id</xsl:element>
               <xsl:element name="CcmFifConcatStringsInCont">
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">EASTER-</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_service_1</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">-</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>

            <xsl:element name="CcmFifConcatStringsCmd">
               <xsl:element name="command_id">concat_transaction_id_1</xsl:element>
               <xsl:element name="CcmFifConcatStringsInCont">
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">concat_transaction_id</xsl:element>
                        <xsl:element name="field_name">output_string</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">1</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConcatStringsCmd">
               <xsl:element name="command_id">concat_transaction_id_2</xsl:element>
               <xsl:element name="CcmFifConcatStringsInCont">
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">concat_transaction_id</xsl:element>
                        <xsl:element name="field_name">output_string</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">2</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConcatStringsCmd">
               <xsl:element name="command_id">concat_transaction_id_3</xsl:element>
               <xsl:element name="CcmFifConcatStringsInCont">
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">concat_transaction_id</xsl:element>
                        <xsl:element name="field_name">output_string</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">3</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConcatStringsCmd">
               <xsl:element name="command_id">concat_transaction_id_4</xsl:element>
               <xsl:element name="CcmFifConcatStringsInCont">
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">concat_transaction_id</xsl:element>
                        <xsl:element name="field_name">output_string</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">4</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- read the notifications for the four transaction ids -->
            <xsl:element name="CcmFifReadExternalNotificationCmd">
               <xsl:element name="command_id">read_sim_card_order_1</xsl:element>
               <xsl:element name="CcmFifReadExternalNotificationInCont">
                  <xsl:element name="transaction_id_ref">
                     <xsl:element name="command_id">concat_transaction_id_1</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
                  <xsl:element name="target_system">SLSFIF</xsl:element>
                  <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                  <xsl:element name="ignore_empty_result">Y</xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationCmd">
               <xsl:element name="command_id">read_sim_card_order_2</xsl:element>
               <xsl:element name="CcmFifReadExternalNotificationInCont">
                  <xsl:element name="transaction_id_ref">
                     <xsl:element name="command_id">concat_transaction_id_2</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
                  <xsl:element name="target_system">SLSFIF</xsl:element>
                  <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                  <xsl:element name="ignore_empty_result">Y</xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationCmd">
               <xsl:element name="command_id">read_sim_card_order_3</xsl:element>
               <xsl:element name="CcmFifReadExternalNotificationInCont">
                  <xsl:element name="transaction_id_ref">
                     <xsl:element name="command_id">concat_transaction_id_3</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
                  <xsl:element name="target_system">SLSFIF</xsl:element>
                  <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                  <xsl:element name="ignore_empty_result">Y</xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationCmd">
               <xsl:element name="command_id">read_sim_card_order_4</xsl:element>
               <xsl:element name="CcmFifReadExternalNotificationInCont">
                  <xsl:element name="transaction_id_ref">
                     <xsl:element name="command_id">concat_transaction_id_4</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
                  <xsl:element name="target_system">SLSFIF</xsl:element>
                  <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                  <xsl:element name="ignore_empty_result">Y</xsl:element>
               </xsl:element>
            </xsl:element>

            <xsl:element name="CcmFifConcatStringsCmd">
               <xsl:element name="command_id">concat_results</xsl:element>
               <xsl:element name="CcmFifConcatStringsInCont">
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">read_sim_card_order_1</xsl:element>
                        <xsl:element name="field_name">value_found</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">;</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">read_sim_card_order_2</xsl:element>
                        <xsl:element name="field_name">value_found</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">;</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">read_sim_card_order_3</xsl:element>
                        <xsl:element name="field_name">value_found</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">;</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">read_sim_card_order_4</xsl:element>
                        <xsl:element name="field_name">value_found</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifMapStringCmd">
               <xsl:element name="command_id">map_notification_id</xsl:element>
               <xsl:element name="CcmFifMapStringInCont">
                  <xsl:element name="input_string_type">xxx</xsl:element>
                  <xsl:element name="input_string_ref">
                     <xsl:element name="command_id">concat_results</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
                  <xsl:element name="output_string_type">notificationId</xsl:element>
                  <xsl:element name="string_mapping_list">
                     <xsl:element name="CcmFifStringMappingCont">
                        <xsl:element name="input_string">N;N;N;N</xsl:element>
                        <xsl:element name="output_string_ref">
                           <xsl:element name="command_id">concat_transaction_id_1</xsl:element>
                           <xsl:element name="field_name">output_string</xsl:element>
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifStringMappingCont">
                        <xsl:element name="input_string">Y;N;N;N</xsl:element>
                        <xsl:element name="output_string_ref">
                           <xsl:element name="command_id">concat_transaction_id_2</xsl:element>
                           <xsl:element name="field_name">output_string</xsl:element>
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifStringMappingCont">
                        <xsl:element name="input_string">Y;Y;N;N</xsl:element>
                        <xsl:element name="output_string_ref">
                           <xsl:element name="command_id">concat_transaction_id_3</xsl:element>
                           <xsl:element name="field_name">output_string</xsl:element>
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifStringMappingCont">
                        <xsl:element name="input_string">Y;Y;Y;N</xsl:element>
                        <xsl:element name="output_string_ref">
                           <xsl:element name="command_id">concat_transaction_id_4</xsl:element>
                           <xsl:element name="field_name">output_string</xsl:element>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="no_mapping_error">Y</xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- Write the external Notification for the createMobilePhoneContract transaction -->
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
               <xsl:element name="command_id">create_sim_notification</xsl:element>
               <xsl:element name="CcmFifCreateExternalNotificationInCont">
                  <xsl:element name="effective_date">
                     <xsl:value-of select="$today"/>
                  </xsl:element>
                  <xsl:element name="transaction_id_ref">
                     <xsl:element name="command_id">map_notification_id</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
                  <xsl:element name="processed_indicator">N</xsl:element>
                  <xsl:element name="notification_action_name">simCardOrdered</xsl:element>
                  <xsl:element name="target_system">SLSFIF</xsl:element>
                  <xsl:element name="parameter_value_list">
                     <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
                        <xsl:element name="parameter_value_ref">
                           <xsl:element name="command_id">find_service_1</xsl:element>
                           <xsl:element name="field_name">service_subscription_id</xsl:element>
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">articleNumber</xsl:element>
                        <xsl:element name="parameter_value">
                           <xsl:value-of select="request-param[@name='articleNumber']"/>
                        </xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">transactionID</xsl:element>
                        <xsl:element name="parameter_value">
                           <xsl:value-of select="request-param[@name='transactionID']"/>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:if>

      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
