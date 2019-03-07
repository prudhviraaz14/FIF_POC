
<xsl:if test="request-param[@name='clientName'] != 'CODB'">  
    <!-- Look for the ISDN service in the external notification if productSubscriptionId is not provided --> 
    <xsl:if test="request-param[@name='DSLServiceSubscriptionId'] = ''">          
      <xsl:variable name="Type">
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable> 
      <xsl:element name="CcmFifReadExternalNotificationCmd">
        <xsl:element name="command_id">read_external_notification_ss</xsl:element>
        <xsl:element name="CcmFifReadExternalNotificationInCont">
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="parameter_name">   
            <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>  
          </xsl:element>                 
        </xsl:element>
      </xsl:element>        
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">read_external_notification_ss</xsl:element>
            <xsl:element name="field_name">parameter_value</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:if>
  
    <!-- Look for the ISDN/DSL-R service if productSubscriptionId is provided --> 
    <xsl:if test="(request-param[@name='DSLServiceSubscriptionId'] != '')">   
     
      <!-- Look for the NGN-DSL service -->    
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='DSLServiceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>           
        </xsl:element>
      </xsl:element>

        <!-- Find the DSL is BITSREAM. If found, no reconfiguration is needed -->
        <xsl:element name="CcmFifValidateSCValueCmd">
            <xsl:element name="command_id">find_bitstream_service_code</xsl:element>
            <xsl:element name="CcmFifValidateSCValueInCont">
                <xsl:element name="value_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>          
                    <xsl:element name="field_name">service_code</xsl:element>            
                </xsl:element>      
                <xsl:element name="allowed_values">
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">I1213</xsl:element>
                    </xsl:element>   
                </xsl:element>
            </xsl:element>
        </xsl:element>
        
        <!-- find an open customer order for the main service -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
            <xsl:element name="command_id">find_dsl_stp</xsl:element>
            <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="service_subscription_id_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>         
                <xsl:element name="no_stp_error">N</xsl:element>
                <xsl:element name="find_stp_parameters">            
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="customer_order_state">DEFINED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">2</xsl:element>
                    <xsl:element name="customer_order_state">DEFINED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="customer_order_state">RELEASED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">2</xsl:element>
                    <xsl:element name="customer_order_state">RELEASED</xsl:element>
                  </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>			
        
        <!-- concat results of two recent commands for use in process indicator --> 
        <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">concat_parameters_1</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
                <xsl:element name="input_string_list">
                    <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_bitstream_service_code</xsl:element>
                        <xsl:element name="field_name">service_code_valid</xsl:element>					
                    </xsl:element>
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">_</xsl:element>							
                    </xsl:element>
                    <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_dsl_stp</xsl:element>
                        <xsl:element name="field_name">stp_found</xsl:element>							
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
             
      <!-- Reconfigure Service Subscription  without the multimedia VC-->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>	
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Reason for reconfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">MM-Änderung</xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>						
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_parameters_1</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y_N</xsl:element>          
        </xsl:element>
      </xsl:element>        
    
      <!--Reconfigure Service Subscription  with the multimedia VC -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_1</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>	
            </xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- Multimedia-VC -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1323</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='multimediaProduct']"/>
                </xsl:element>
              </xsl:element>
              <!-- Reason for reconfiguration -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0943</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">MM-Änderung</xsl:element>
              </xsl:element>
              <!-- Aktivierungsdatum -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0909</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="$desiredDateOPM"/>
                </xsl:element>
              </xsl:element>	
              <!-- set ACS -->
              <xsl:if test="request-param[@name='setACSIndicator'] = 'Y'">
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0196</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">Ja</xsl:element>
                </xsl:element>
              </xsl:if>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_parameters_1</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">N_N</xsl:element>          
          </xsl:element>
        </xsl:element>    
      <!-- Create Customer Order reconfigure NGN-DSL  -->        
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
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
          <xsl:element name="provider_tracking_no">001</xsl:element> 
          <xsl:element name="super_customer_tracking_id">
            <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>            
          <xsl:element name="service_ticket_pos_list">
            <!-- I1210 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
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
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>  
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>  
      
    </xsl:if>
</xsl:if>

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
          <xsl:element name="product_code">I1305</xsl:element>        
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
          <xsl:element name="service_code">I1305</xsl:element>
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
            <!-- I1312 Grund der Neukonfiguration-->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1312</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">unbekannt</xsl:element>
            </xsl:element> 
            <!-- allow Partial Cancel -->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1313</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='allowPartialCancel']"/>
              </xsl:element>
            </xsl:element> 
            <!-- FSKLevel --> 
              <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1314</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='FSKLevel']"/>
              </xsl:element>
              </xsl:element>     
            <!-- Language -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1316</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='language']"/>
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
            <!-- Order variant -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1331</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='orderVariant']"/>
              </xsl:element>
            </xsl:element>  
            <!--I1332- Typ der Erstbestellung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1332</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='initialOrderType']"/>
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
              <xsl:element name="configured_value">Anlage TV-Center</xsl:element>
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
 
      <xsl:if
        test="count(request-param-list[@name='featureServiceList']/request-param-list-item) != 0">
        <!-- Create Abo Services -->
        <xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">          
          <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>          
          <!-- Add feature services -->
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="$ServiceCode"/>
              </xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>	
              </xsl:element>     
              <xsl:element name="reason_rd">
                <xsl:value-of select="$ReasonRd"/>
              </xsl:element>
              <xsl:if test="//request-param[@name='accountNumber'] != ''">	
                <xsl:element name="account_number">
                  <xsl:value-of select="//request-param[@name='accountNumber']"/>
                </xsl:element>
              </xsl:if>
              <xsl:if test="//request-param[@name='accountNumber'] = ''">					
                <xsl:element name="account_number_ref">
                  <xsl:element name="command_id">read_external_notification_2</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
              </xsl:if> 
              <xsl:element name="service_characteristic_list">       
                <!--Z0100 Network Element Id-->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">Z0100</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='networkElementId']"/>
                  </xsl:element>
                </xsl:element>
                <xsl:if test="request-param[@name='hotSubscription'] != ''">
                  <!--I1320 Hot Subscription-->
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">I1320</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                      <xsl:value-of select="request-param[@name='hotSubscription']"/>
                    </xsl:element>
                  </xsl:element> 
                </xsl:if>
                <!--I1321 Identifier in Technik-->
                <xsl:if test="request-param[@name='networkIdentifier'] != ''">
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">I1321</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                      <xsl:value-of select="request-param[@name='networkIdentifier']"/>
                    </xsl:element>
                  </xsl:element> 
                </xsl:if>
                <!--I1322 Gültig bis-->
                <xsl:if test="request-param[@name='enddate'] != ''">
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">I1322</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                      <xsl:value-of select="request-param[@name='enddate']"/>
                    </xsl:element>
                  </xsl:element> 
                </xsl:if>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:if>


<xsl:choose>
  <xsl:when test="request-param[@name='clientName'] != 'CODB'">    
    <!-- look for a voice bundle (item) -->
    <xsl:element name="CcmFifFindBundleCmd">
      <xsl:element name="command_id">find_bundle_1</xsl:element>
      <xsl:element name="CcmFifFindBundleInCont">
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:when>
  <xsl:otherwise>
    <!-- TODO also aufpassen bei Providerwechsel, VPW, da auch findBundle aufrufen -->
    <xsl:element name="CcmFifReadExternalNotificationCmd">
      <xsl:element name="command_id">find_bundle_1</xsl:element>
      <xsl:element name="CcmFifReadExternalNotificationInCont">
        <xsl:element name="transaction_id">
          <xsl:value-of select="request-param[@name='requestListId']"/>
        </xsl:element>
        <xsl:element name="parameter_name">
          <xsl:text>BUNDLE_ID</xsl:text>
        </xsl:element>
      </xsl:element>
    </xsl:element>    
  </xsl:otherwise>  
</xsl:choose>

<!-- add the new bundle item if a bundle is found -->
<xsl:element name="CcmFifModifyBundleItemCmd">
  <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">
              <xsl:choose>
                <xsl:when test="request-param[@name='clientName'] != 'CODB'">bundle_id</xsl:when>
                <xsl:otherwise>parameter_value</xsl:otherwise>  
              </xsl:choose>              
            </xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">TV_CENTER</xsl:element>  
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
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
            <xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">
              <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">
                  <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
                </xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:for-each> 
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
          <xsl:element name="contact_type_rd">ADD_TV_CENTER</xsl:element>        
          <xsl:element name="short_description">Create TV Center contract</xsl:element>
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
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
                        </xsl:element> 
                        <xsl:element name="parameter_value_ref">
                          <xsl:element name="command_id">create_co_1</xsl:element> 
                          <xsl:element name="field_name">customer_order_id</xsl:element> 
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
      <xsl:if test="request-param[@name='clientName'] != 'CODB'">
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
                <xsl:element name="parameter_value">createTVCenterContract</xsl:element>
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
                  <xsl:text>TV Center contract has been created on </xsl:text>
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
