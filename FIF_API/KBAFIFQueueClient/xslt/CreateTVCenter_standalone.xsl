        <!-- Add Order Form Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commitment_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>   
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_code">I1306</xsl:element>        
          <xsl:element name="pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariff']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_of_1</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='boardSignName'] != ''">                
            <xsl:element name="board_sign_name">
              <xsl:value-of select="request-param[@name='boardSignName']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='boardSignName'] = ''">                
              <xsl:element name="board_sign_name">ARCOR</xsl:element>
          </xsl:if>
          <xsl:element name="board_sign_date">
            <xsl:value-of select="request-param[@name='boardSignDate']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='primaryCustSignName'] != ''">                
            <xsl:element name="primary_cust_sign_name">
              <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='primaryCustSignName'] = ''">                
            <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          </xsl:if>
          <xsl:element name="primary_cust_sign_date">
            <xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_name">
            <xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_date">
            <xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>   
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_product_commitment_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Multimedia main access Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1306</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>	
          </xsl:element>           
          <xsl:if test="request-param[@name='accountNumber'] != ''">	
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='accountNumber'] = ''">					
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">read_external_notification_2</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>                   
          <xsl:element name="service_characteristic_list">
            <!-- Address -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:if test="request-param[@name='addressId'] = ''">
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">create_addr_1</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='addressId'] != ''">
                <xsl:element name="address_id">
                  <xsl:value-of select="request-param[@name='addressId']"/>
                </xsl:element>
              </xsl:if>
            </xsl:element>            
            <!-- Language -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1316</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='language']"/>
              </xsl:element>
            </xsl:element>         
            <!-- Order variant -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1331</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='orderVariant']"/>
              </xsl:element>
            </xsl:element>              
            <!-- I1333 MULTIMEDIA-ACCOUNT -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">I1330</xsl:element>
              <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
              <xsl:element name="network_account">
                <xsl:value-of select="request-param[@name='multimediaAccount']"/>
              </xsl:element>
            </xsl:element>                 
            <!-- Reason for reconfiguration -->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1334</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">unbekannt</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">V0001</xsl:element>
              <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
              <xsl:element name="country_code">
                <xsl:value-of select="substring-before(request-param[@name='accessNumber'], ';')"/>
              </xsl:element>
              <xsl:element name="city_code">
                <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber'], ';'), ';')"/>
              </xsl:element>
              <xsl:element name="local_number">
                <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>
            <!--  Kondition/Rabatt -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0097</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='rabatt']"/>
              </xsl:element>
            </xsl:element>
            <!--  Kondition/Rabatt ID -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0162</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='rabattId']"/>
              </xsl:element>
            </xsl:element>            
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>            
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element> 
            <!-- Comment -->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Anlage TV-Center Standalone</xsl:element>
            </xsl:element>                              
          </xsl:element>
        </xsl:element>
      </xsl:element>

    <!-- Add Feature Service I1356 Monthly Charge (Monatspreis) -->
    <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_monthly_charge</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">I1356</xsl:element>
            <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>	
            </xsl:element> 
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
                <xsl:value-of select="$ReasonRd"/>
            </xsl:element>
            <xsl:if test="request-param[@name='accountNumber'] != ''">	
                <xsl:element name="account_number">
                    <xsl:value-of select="request-param[@name='accountNumber']"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='accountNumber'] = ''">					
                <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list"/>
        </xsl:element>
    </xsl:element>
    
    <!-- Add Feature Service I1357 Setup Charge (Einrichtungspreis) -->
    <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_setup_charge</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">I1357</xsl:element>
            <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>	
            </xsl:element> 
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
                <xsl:value-of select="$ReasonRd"/>
            </xsl:element>
            <xsl:if test="request-param[@name='accountNumber'] != ''">	
                <xsl:element name="account_number">
                    <xsl:value-of select="request-param[@name='accountNumber']"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='accountNumber'] = ''">					
                <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
            </xsl:if>  
            <xsl:element name="service_characteristic_list"/>
        </xsl:element>
    </xsl:element>
            

      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>   
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>    
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">                     
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element> 
          </xsl:if>
          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''">   
            <xsl:element name="provider_tracking_no">003h</xsl:element>    
            <xsl:element name="super_customer_tracking_id">
              <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>                                  
          <xsl:element name="service_ticket_pos_list">
            <!-- Multimedia -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
              <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">add_service_monthly_charge</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>   
              <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">add_service_setup_charge</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>                                 
          </xsl:element>
          <xsl:element name="e_shop_id">
			<xsl:value-of select="request-param[@name='eShopID']"/>
		  </xsl:element>
        </xsl:element>
      </xsl:element>
                
     <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>   
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>           
      
      <!-- Create Contact for Service Addition -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>          
          <xsl:element name="contact_type_rd">ADD_TV_CENTER_SA</xsl:element>        
          <xsl:element name="short_description">Create TV Center standalone</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Desired Date: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create External notification  if requestListId is set -->
      <xsl:if test="request-param[@name='requestListId'] != ''">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_external_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">CreateTVCenterContract</xsl:element>
            <xsl:element name="target_system">FIF</xsl:element>
            <xsl:element name="parameter_value_list">
                <xsl:choose>
                    <xsl:when test="request-param[@name='functionID'] != ''">
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">
                                <xsl:value-of select="request-param[@name='functionID']"/>
                                <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
                            </xsl:element> 
                            <xsl:element name="parameter_value_ref">
                                <xsl:element name="command_id">add_service_1</xsl:element> 
                                <xsl:element name="field_name">service_subscription_id</xsl:element> 
                            </xsl:element>
                        </xsl:element> 
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">TV_CENTER_SERVICE_SUBSCRIPTION_ID</xsl:element> 
                            <xsl:element name="parameter_value_ref">
                                <xsl:element name="command_id">add_service_1</xsl:element> 
                                <xsl:element name="field_name">service_subscription_id</xsl:element> 
                            </xsl:element>
                        </xsl:element> 
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Create external notification -->
      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>                           				
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>						
                <xsl:if test="request-param[@name='customerNumber'] != ''">	
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='customerNumber'] = ''">	
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                  </xsl:element>
                </xsl:if>											
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">CreateTVCenterContract</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:if test="request-param[@name='userName'] != ''">              
                  <xsl:element name="parameter_name">USER_NAME</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='userName']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='userName'] = ''">              
                  <xsl:element name="parameter_name">USER_NAME</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='clientName']"/>
                  </xsl:element>
                </xsl:if>            
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
                  <xsl:text>TV Center stand alone contract has been created on </xsl:text>
                  <xsl:value-of select="$today"/>	
                  <xsl:text> by </xsl:text>  
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:text> with product </xsl:text>  
                  <xsl:value-of select="request-param[@name='multimediaProduct']"/> 
                  <xsl:text>.</xsl:text>      
                  <xsl:if test="request-param[@name='pricingStructureBillingName'] != ''">
                    <xsl:text>  Pricing Structure Billing Name: </xsl:text>
                    <xsl:value-of select="request-param[@name='pricingStructureBillingName']"/>
                    <xsl:text>.</xsl:text>
                  </xsl:if>
                </xsl:element>
              </xsl:element>					
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
