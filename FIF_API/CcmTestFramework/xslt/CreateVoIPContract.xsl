<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a voice over IP contract. IT15309 - VoIP Second Line.

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
    
    <!-- Convert the desired date to OPM format -->
    <xsl:variable name="desiredDateOPM"
      select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
      
    <!-- Calculate today and one day before the desired date -->
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    
    <xsl:element name="Command_List">
      
      <!-- Look for the ISDN/DSL-R service if productSubscriptionId is provided --> 
      <xsl:if test="(request-param[@name='productSubscriptionId'] != '')">   
        <xsl:element name="CcmFifFindServiceSubsForProductCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsForProductInCont">
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="service_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0010</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0011</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1043</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I104A</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        </xsl:if>
      
      <!-- Look for the ISDN service in the external notification if productSubscriptionId is not provided --> 
        <xsl:if test="(request-param[@name='productSubscriptionId'] = '')">         
            <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="CcmFifReadExternalNotificationInCont">
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="parameter_name">ISDN_SERVICE_SUBSCRIPTION_ID</xsl:element>                        
              </xsl:element>
            </xsl:element>
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">read_external_notification_1</xsl:element>
                <xsl:element name="field_name">parameter_value</xsl:element>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      
      <!-- Get Entity Information -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity_1</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Location Address  if the address id is not provided. SPN-FIF-000039525-O-->
      <xsl:if test="request-param[@name='addressId'] = ''">
      <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_addr_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <!-- HH 31.07.2003 : Added missing element "address_type", defaulted to "LOKA" -->
          <xsl:element name="address_type">LOKA</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='street']"/>
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
          <!-- Added missing element "country_code", defaulted to "DE" -->
          <xsl:element name="country_code">DE</xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

      <!-- Normalize Address  if the address id is provided. -->
      <xsl:if test="request-param[@name='addressId'] != ''">
		<xsl:element name="CcmFifNormalizeAddressCmd">
			<xsl:element name="command_id">normalize_address_1</xsl:element>
			<xsl:element name="CcmFifNormalizeAddressInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="address_id">
					<xsl:value-of select="request-param[@name='addressId']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
      </xsl:if>

      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>         
          <xsl:element name="term_dur_value">
            <xsl:value-of select="request-param[@name='termDurValue']"/>
          </xsl:element>
          <xsl:element name="term_dur_unit">
            <xsl:value-of select="request-param[@name='termDurUnit']"/>
          </xsl:element>
          <xsl:element name="term_start_date">
            <xsl:value-of select="request-param[@name='termStartDate']"/>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value_vf">
			<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
		  </xsl:element>  
          <xsl:element name="sales_org_date">
            <xsl:value-of select="request-param[@name='salesOrgDate']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
          <xsl:element name="assoc_skeleton_cont_num">
            <xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
          </xsl:element>
          <xsl:element name="auto_extent_period_value">
            <xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
          </xsl:element>                         
          <xsl:element name="auto_extent_period_unit">
            <xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
          </xsl:element>                         
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='autoExtensionInd']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Order Form Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commitment_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_code">VI201</xsl:element>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_product_commitment_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Voice over IP main Service VI201 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">VI201</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>      
          <xsl:if test="request-param[@name='accountNumber'] = ''">          
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element> 
          </xsl:if> 
          <xsl:if test="request-param[@name='accountNumber'] != ''">          
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
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
            <!-- Anzahl der neue Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">INTEGER</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='accessNumberCount']"/>
              </xsl:element>
            </xsl:element>            
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>
            
            <xsl:if test="(request-param[@name='productSubscriptionId'] = '')">   
              <!-- Bundle Kennzeichen -->
               <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI047</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                 <xsl:element name="configured_value">DSL_NEU</xsl:element>
              </xsl:element> 
              <!-- Synchronisation -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI049</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">JA</xsl:element>
              </xsl:element>               
            </xsl:if>
            
            <xsl:if test="(request-param[@name='productSubscriptionId'] != '')">   
              <!-- Bundle Kennzeichen -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI047</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='bundleMark']"/>
                  </xsl:element>
                </xsl:element>
             </xsl:if>
           
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Rabatt -->
            <xsl:if test="request-param[@name='rabatt'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0097</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='rabatt']"/>                  
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Kündigung Preselect -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI322</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='terminatePreselect']"/>                  
              </xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Voice over IP  Service VI220  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_2</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">VI220</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element> 
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>     
          <xsl:if test="request-param[@name='accountNumber'] = ''">          
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element> 
          </xsl:if> 
          <xsl:if test="request-param[@name='accountNumber'] != ''">          
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>  
          </xsl:if> 
          <xsl:element name="service_characteristic_list">           
            <!-- Monatspreis VoIP --> 
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI025</xsl:element>
              <xsl:element name="data_type">DECIMAL</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>             
          </xsl:element>
        </xsl:element>
      </xsl:element>
    
      <!-- Add Service V0025  Sperre - Ausland if requested -->
      <xsl:if test="request-param[@name='blockInternationalNumbers'] = 'Y' ">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_3</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subscription_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0025</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element> 
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>	
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>     
            <xsl:if test="request-param[@name='accountNumber'] = ''">          
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element> 
            </xsl:if> 
            <xsl:if test="request-param[@name='accountNumber'] != ''">          
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>  
            </xsl:if> 
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Add Service V0026 Sperre - außerhalb EU if requested  -->
      <xsl:if test="request-param[@name='blockNonEuropeanNumbers'] = 'Y' "> 
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_4</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subscription_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0026</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element> 
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>	
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>     
            <xsl:if test="request-param[@name='accountNumber'] = ''">          
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element> 
            </xsl:if> 
            <xsl:if test="request-param[@name='accountNumber'] != ''">          
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>  
            </xsl:if> 
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Add Service V0027 Sperre - 0190/0900 if requested  -->
      <xsl:if test="request-param[@name='blockPremiumNumbers'] = 'Y' "> 
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_5</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subscription_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0027</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element> 
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>	
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>     
            <xsl:if test="request-param[@name='accountNumber'] = ''">          
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element> 
            </xsl:if> 
            <xsl:if test="request-param[@name='accountNumber'] != ''">          
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>  
            </xsl:if> 
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Add Feature  Service S0106 Service Level Classic -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_6</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">S0106</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>  
          <xsl:if test="request-param[@name='accountNumber']!=''">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_characteristic_list">
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
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
      
      <!-- Create a new bundle if no one has been found -->
      <xsl:element name="CcmFifModifyBundleCmd">
        <xsl:element name="command_id">modify_bundle_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Get bundle item type rd from reference data -->
      <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
        <xsl:element name="command_id">get_ref_data_1</xsl:element>
        <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
          <xsl:element name="group_code">SERV_BLD</xsl:element>
          <xsl:element name="primary_value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- add the new bundle item if a bundle is found -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- add a new bundle item for the given service subscription id -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_2</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">modify_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd_ref">
            <xsl:element name="command_id">get_ref_data_1</xsl:element>
            <xsl:element name="field_name">secondary_value</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- add the new  bundle item to the new bundle if created only -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_3</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">modify_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>            
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>                             
          <xsl:element name="provider_tracking_no">003v</xsl:element>        
          <xsl:element name="service_ticket_pos_list">
            <!-- VI201 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- VI220 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>  
            <!-- V0025 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_3</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <!-- V0026 -->            
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_4</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <!-- V0027 -->            
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_5</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <!-- S0106 -->            
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_6</xsl:element>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>           
      
      <!-- Create Contact for Service Addition -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">VOIP_CONTRACT</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Service Code: VI201</xsl:text>
            <xsl:text>&#xA;Desired Date: </xsl:text>
            <xsl:if test="request-param[@name='desiredDate'] != ''">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:if>
            <xsl:if test="request-param[@name='desiredDate'] = ''">
              <xsl:value-of select="$today"/>
            </xsl:if>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create external notification -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_external_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:if test="request-param[@name='desiredDate'] != ''">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:if>
            <xsl:if test="request-param[@name='desiredDate'] = ''">
              <xsl:value-of select="$today"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="notification_action_name">createPOSNotification</xsl:element>
          <xsl:element name="target_system">POS</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">CONTACT</xsl:element>
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
                <xsl:if test="request-param[@name='desiredDate'] != ''">
                  <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:if>
                <xsl:if test="request-param[@name='desiredDate'] = ''">
                  <xsl:value-of select="$today"/>
                </xsl:if>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BARCODE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
              <xsl:if test="request-param[@name='accountNumber'] != ''"> 
                <xsl:element name="parameter_value"> 
                  <xsl:value-of select="request-param[@name='accountNumber']"/>
                </xsl:element>
              </xsl:if> 
              <xsl:if test="request-param[@name='accountNumber'] = ''"> 
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">account_number</xsl:element>
                </xsl:element>
              </xsl:if>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CONTRACT_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">create_order_form_1</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_ORDER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">create_co_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SALES_ORGANISATION_NUMBER</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BOARD_SIGN_DATE</xsl:element>
              <xsl:if test="request-param[@name='boardSignName'] != ''"> 
                <xsl:element name="parameter_value"> 
                  <xsl:value-of select="request-param[@name='boardSignDate']"/>
                </xsl:element>
              </xsl:if> 
              <xsl:if test="request-param[@name='boardSignName'] = ''"> 
                <xsl:element name="parameter_value"> 
                  <xsl:value-of select="$today"/>
                </xsl:element>
              </xsl:if>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BOARD_SIGN_NAME</xsl:element>
                 <xsl:if test="request-param[@name='boardSignName'] != ''">   
                   <xsl:element name="parameter_value">             
                      <xsl:value-of select="request-param[@name='boardSignName']"/>
                   </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='boardSignName'] = ''">                
                  <xsl:element name="parameter_value">ARCOR</xsl:element>
                </xsl:if>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRIMARY_CUST_SIGN_DATE</xsl:element>
              <xsl:if test="request-param[@name='primaryCustSignDate'] != ''"> 
                <xsl:element name="parameter_value"> 
                  <xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
                </xsl:element>
              </xsl:if> 
              <xsl:if test="request-param[@name='primaryCustSignDate'] = ''"> 
                <xsl:element name="parameter_value"> 
                  <xsl:value-of select="$today"/>
                </xsl:element>
              </xsl:if>                 
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRIMARY_CUST_SIGN_NAME</xsl:element>
              <xsl:if test="request-param[@name='primaryCustSignName'] != ''">   
                <xsl:element name="parameter_value">              
                  <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='primaryCustSignName'] = ''">                
                <xsl:element name="parameter_value">Kunde</xsl:element>
              </xsl:if>              
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_CODE</xsl:element>
              <xsl:element name="parameter_value">VI201</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TARIFF_CODE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='tariff']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>VoIP Second Line</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- Create External notification  if requestListId is set -->
      <xsl:if test="request-param[@name='requestListId'] != ''">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_external_notification_2</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">CreateVoIPContract</xsl:element>
            <xsl:element name="target_system">FIF</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">VoIP_SERVICE_SUBSCRIPTION_ID</xsl:element> 
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">add_service_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element> 
              <xsl:if test="request-param[@name='terminatePreselect'] != ''">             
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element> 
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">create_co_1</xsl:element> 
                    <xsl:element name="field_name">customer_order_id</xsl:element> 
                  </xsl:element>
                </xsl:element> 
              </xsl:if>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">VoIP_DETAILED_REASON_RD</xsl:element>
                <xsl:element name="parameter_value">UPGRADE_VOIP</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
