<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a voice over IP contract. IT15309 - VoIP Second Line.

  @author schwarje
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
      
    <xsl:element name="Command_List">
 
      <!-- Look for the ISDN/DSL-R service -->    
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Ensure, that the access number/ service  belongs to an ISDN service (V0010, V0011) or an DSL-R service (I1043) -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_value_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICE_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">SERVICE_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">V0010</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">V0011</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1043</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
   
      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>          
          <xsl:element name="notice_per_dur_value">
            <xsl:value-of select="request-param[@name='noticePerDurValue']"/>
          </xsl:element>
          <xsl:element name="notice_per_dur_unit">
            <xsl:value-of select="request-param[@name='noticePerDurUnit']"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
            <xsl:value-of select="request-param[@name='noticePerStartDate']"/>
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
          <xsl:element name="sales_org_date">
            <xsl:value-of select="request-param[@name='salesOrgDate']"/>
          </xsl:element>
          <xsl:element name="termination_restriction">
            <xsl:value-of select="request-param[@name='terminationRestriction']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
          <xsl:element name="assoc_skeleton_cont_num">
            <xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
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
          <xsl:element name="board_sign_name">ARCOR</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
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
            <!-- Address -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_id">
                <xsl:value-of select="request-param[@name='addressId']"/>
              </xsl:element>
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
            <!-- Bundle Kennzeichen -->
            <xsl:if test="request-param[@name='bundleMark'] != ''">            
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
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Voice over IP  Service V0099 if the bonusIndicator is set -->
      <xsl:if test="request-param[@name='bonusIndicator'] = 'Y'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subscription_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0099</xsl:element>
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
            <!-- Bemerkung -->
            <xsl:element name="service_characteristic_list">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0008</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">NOT_RELEVANT</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
 

      <!-- Add Voice over IP  Service VI220  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_3</xsl:element>
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
            <!-- Bemerkung -->   
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
   
      <!-- Add Service V0025  Sperre - Ausland if requested -->
      <xsl:if test="request-param[@name='blockInternationalNumbers'] = 'Y' ">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_4</xsl:element>
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
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
       
      <!-- Add Service V0026 Sperre - außerhalb EU if requested  -->
      <xsl:if test="request-param[@name='blockNonEuropeanNumbers'] = 'Y' "> 
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_5</xsl:element>
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
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Add Service V0027 Sperre - 0190/0900 if requested  -->
      <xsl:if test="request-param[@name='blockPremiumNumbers'] = 'Y' "> 
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_6</xsl:element>
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
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
                   
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

      
      <!-- add the new voice over IP  bundle item if a bundle is found -->
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
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
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
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- add the new voice over IP  bundle item to the new bundle if created only -->
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
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <!--  <xsl:element name="cust_order_description"></xsl:element> -->
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
             <xsl:element name="provider_tracking_no">001v</xsl:element> 
          </xsl:if>          
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
          <xsl:element name="provider_tracking_no">
            <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="super_customer_tracking_id">
            <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
          </xsl:element>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <!-- VI201 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- V0099 -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_2</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            <!-- VI220 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_3</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- V0025 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_4</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <!-- V0026 -->            
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_5</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <!-- V0027 -->            
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_6</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>                                               
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Release stand alone Customer Order for VoIP Services -->
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
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
