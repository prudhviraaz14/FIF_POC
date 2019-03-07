<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating changing contract conditions
  
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
    <xsl:element name="Command_List">
    
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>  
      
      <xsl:variable name="desiredDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='desiredDate'] = ''">
            <xsl:value-of select="$today"/>
          </xsl:when>        
          <xsl:when test ="dateutils:compareString(request-param[@name='desiredDate'], $today) = '-1'">
            <xsl:value-of select="$today"/>
          </xsl:when>          
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>     

      <xsl:variable name="termStartDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='termStartDate'] = 'today'">
            <xsl:value-of select="$today"/>
          </xsl:when>        
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='termStartDate']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>     
                                    
      <!-- find service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
      <!-- Get Order Form Data for APPROVED row -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number_ref">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="field_name">contract_number</xsl:element>							
          </xsl:element>
          <xsl:element name="target_state">APPROVED</xsl:element>
          <xsl:element name="ignore_not_exists">Y</xsl:element>
          <xsl:element name="most_effective">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- cancel order form version -->
      <xsl:element name="CcmFifTransitionLegalAgreementCmd">
        <xsl:element name="command_id">transition_la_1</xsl:element>
        <xsl:element name="CcmFifTransitionLegalAgreementInCont">
          <xsl:element name="contract_number_ref">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="field_name">contract_number</xsl:element>							
          </xsl:element>
          <xsl:element name="state_rd">CANCELED</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
            <xsl:element name="field_name">record_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Get Order Form Data for CREATED row -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number_ref">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="field_name">contract_number</xsl:element>							
          </xsl:element>
          <xsl:element name="target_state">CREATED</xsl:element>
          <xsl:element name="ignore_not_exists">Y</xsl:element>
          <xsl:element name="most_effective">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- cancel order form version -->
      <xsl:element name="CcmFifTransitionLegalAgreementCmd">
        <xsl:element name="command_id">transition_la_1</xsl:element>
        <xsl:element name="CcmFifTransitionLegalAgreementInCont">
          <xsl:element name="contract_number_ref">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="field_name">contract_number</xsl:element>							
          </xsl:element>
          <xsl:element name="state_rd">CANCELED</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
            <xsl:element name="field_name">record_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_supported_object</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">contractType</xsl:element>
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type">supportedObjectId</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">O</xsl:element>
              <xsl:element name="output_string_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>							
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">S</xsl:element>
              <xsl:element name="output_string_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='isOnlySpecialTerminationRight'] = 'Y'">
        <!-- Modify contract -->
        <xsl:element name="CcmFifModifyContractDataCmd">
          <xsl:element name="command_id">set_special_term_right</xsl:element>
          <xsl:element name="CcmFifModifyContractDataInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>          	
            </xsl:element>
            <xsl:element name="contract_type_rd_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>          	
            </xsl:element>
            <xsl:element name="special_termination_right">
              <xsl:value-of select="request-param[@name='specialTerminationRight']"/>
            </xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:if test="request-param[@name='isOnlySpecialTerminationRight'] != 'Y'">
        <!-- Renegotiate Order Form  -->
        <xsl:element name="CcmFifRenegotiateOrderFormCmd">
          <xsl:element name="command_id">renegotiate</xsl:element>
          <xsl:element name="CcmFifRenegotiateOrderFormInCont">
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">map_supported_object</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="min_per_dur_value">
              <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
            </xsl:element>
            <xsl:element name="min_per_dur_unit">
              <xsl:value-of select="request-param[@name='newMinPeriodDurationUnit']"/>
            </xsl:element>
            <xsl:element name="term_start_date">
              <xsl:value-of select="$termStartDate"/>
            </xsl:element>
            <xsl:element name="product_commit_list">
              <xsl:element name="CcmFifProductCommitCont">
                <xsl:element name="new_pricing_structure_code">
                  <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="auto_extent_period_value">
              <xsl:value-of select="request-param[@name='newAutoExtentPeriodValue']"/>
            </xsl:element>                         
            <xsl:element name="auto_extent_period_unit">
              <xsl:value-of select="request-param[@name='newAutoExtentPeriodUnit']"/>
            </xsl:element>                         
            <xsl:element name="auto_extension_ind">
              <xsl:value-of select="request-param[@name='newAutoExtensionInd']"/>
            </xsl:element>  
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>          
            <xsl:element name="special_termination_right">
              <xsl:value-of select="request-param[@name='specialTerminationRight']"/>
            </xsl:element>                         
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="required_process_ind">O</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        <!-- Renegotiate SDCPC  -->
        <xsl:element name="CcmFifRenegotiateSDCProductCommitmentCmd">
          <xsl:element name="command_id">renegotiate</xsl:element>
          <xsl:element name="CcmFifRenegotiateSDCProductCommitmentInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">map_supported_object</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="term_start_date">
              <xsl:value-of select="$termStartDate"/>
            </xsl:element>
            <xsl:element name="product_commit_list">
              <xsl:element name="CcmFifProductCommitCont">
                <xsl:element name="old_product_code">
                  <xsl:value-of select="request-param[@name='productCode']"/>
                </xsl:element>
                <xsl:element name="old_pricing_structure_code">
                  <xsl:value-of select="request-param[@name='oldPricingStructureCode']"/>
                </xsl:element>
                <xsl:element name="new_product_code">
                  <xsl:value-of select="request-param[@name='productCode']"/>
                </xsl:element>
                <xsl:element name="new_pricing_structure_code">
                  <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                </xsl:element>
                <xsl:element name="min_per_dur_value">
                  <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
                </xsl:element>
                <xsl:element name="min_per_dur_unit">
                  <xsl:value-of select="request-param[@name='newMinPeriodDurationUnit']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="auto_extent_period_value">
              <xsl:value-of select="request-param[@name='newAutoExtentPeriodValue']"/>
            </xsl:element>                         
            <xsl:element name="auto_extent_period_unit">
              <xsl:value-of select="request-param[@name='newAutoExtentPeriodUnit']"/>
            </xsl:element>                         
            <xsl:element name="auto_extension_ind">
              <xsl:value-of select="request-param[@name='newAutoExtensionInd']"/>
            </xsl:element>  
            <xsl:element name="special_termination_right">
              <xsl:value-of select="request-param[@name='specialTerminationRight']"/>
            </xsl:element>                         
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>          
            <xsl:element name="required_process_ind">S</xsl:element>          
          </xsl:element>
        </xsl:element>      
        
        <!-- Add commissing information  -->
        <xsl:if test="request-param[@name='salesOrganisationNumber'] != ''">
          <xsl:element name="CcmFifAddCommissionInfoCmd">
            <xsl:element name="command_id">add_commission_info</xsl:element>
            <xsl:element name="CcmFifAddCommissionInfoInCont">
              <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">map_supported_object</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="supported_object_type_rd_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>
              <xsl:element name="cio_type_rd">ONE_TIME</xsl:element>
              <xsl:element name="cio_data">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>     
      
        <xsl:if test="request-param[@name='salesOrganisationNumberVF'] != ''">
          <xsl:element name="CcmFifAddCommissionInfoCmd">
            <xsl:element name="command_id">add_commission_info_vf</xsl:element>
            <xsl:element name="CcmFifAddCommissionInfoInCont">
              <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">map_supported_object</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="supported_object_type_rd_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>
              <xsl:element name="cio_type_rd">ONE_TIME_VF</xsl:element>
              <xsl:element name="cio_data">
                <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>     
      </xsl:if>
      
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
              <xsl:element name="value">
                <xsl:choose>
                  <xsl:when test="request-param[@name='isOnlySpecialTerminationRight'] = 'Y'">SUCCESS</xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="request-param[@name='functionStatus']"/>
                  </xsl:otherwise>                  
                </xsl:choose>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifGetContractDatesCmd">
        <xsl:element name="command_id">getContractDates</xsl:element>
        <xsl:element name="CcmFifGetContractDatesInCont">
          <xsl:element name="min_period_dur_value">
            <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_period_dur_unit_rd">
            <xsl:value-of select="request-param[@name='newMinPeriodDurationUnit']"/>
          </xsl:element>
          <xsl:element name="min_period_start_date">
            <xsl:choose>
              <xsl:when test="$termStartDate != ''">
                <xsl:value-of select="$termStartDate"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$today"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="auto_extent_dur_value">
            <xsl:value-of select="request-param[@name='newAutoExtentPeriodValue']"/>
          </xsl:element>
          <xsl:element name="auto_extent_dur_unit_rd">
            <xsl:value-of select="request-param[@name='newAutoExtentPeriodUnit']"/>
          </xsl:element>
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='newAutoExtensionInd']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>            
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
