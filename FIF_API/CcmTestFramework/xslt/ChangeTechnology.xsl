<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an technology change FIF request

  @author banania
-->

<!DOCTYPE XSL [

<!ENTITY ChangeTechnology_ISDN SYSTEM "ChangeTechnology_ISDN.xsl">
<!ENTITY ChangeTechnology_NGN SYSTEM "ChangeTechnology_NGN.xsl">
<!ENTITY TerminateService_ISDN SYSTEM "TerminateService_Default.xsl">
<!ENTITY TerminateService_NGN SYSTEM "TerminateService_NGN.xsl">
<!ENTITY DowngradeToBasis_ISDN SYSTEM "DowngradeToBasis_ISDN.xsl">
<!ENTITY DowngradeToBasis_NGN SYSTEM "DowngradeToBasis_NGN.xsl">
<!ENTITY UpgradeToPremium_ISDN SYSTEM "UpgradeToPremium_ISDN.xsl">
<!ENTITY UpgradeToPremium_NGN SYSTEM "UpgradeToPremium_NGN.xsl">
<!ENTITY DowngradeToBasis_BitStream SYSTEM "DowngradeToBasis_BitStream.xsl">
<!ENTITY UpgradeToPremium_BitStream SYSTEM "UpgradeToPremium_BitStream.xsl">
<!ENTITY ChangeTechnology_BitStream SYSTEM "ChangeTechnology_BitStream.xsl">
<!ENTITY TerminateService_BitStream SYSTEM "TerminateService_BitStream.xsl">
<!ENTITY HandleMMAccessHardware SYSTEM "HandleMMAccessHardware.xsl">
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
      <!-- Generate a FIF date that is one day before the relocation date -->
      <xsl:variable name="oneDayBefore"
        select="dateutils:createFIFDateOffset(request-param[@name='activationDate'], 'DATE', '-1')"/>
      <!-- Convert the termination date to OPM format -->
      <xsl:variable name="relocationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

      <xsl:variable name="terminationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>

       <xsl:variable name="NoticePeriodStartDate">
          <xsl:value-of select="request-param[@name='activationDate']"/>
       </xsl:variable>
           
      <xsl:variable name="TerminationDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable> 
      
      <xsl:variable name="terminationBarcode">
        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
      </xsl:variable>
      
      <xsl:variable name="scenarioType">PRODUCT_CHANGE</xsl:variable>
      
      <xsl:variable name="DSLProductCode">I1204</xsl:variable>
      <xsl:variable name="VoIPProductCode">VI202</xsl:variable>
      <xsl:variable name="ISDNProductCode">V0002</xsl:variable>
      <xsl:variable name="BitStreamDSLProductCode">I1203</xsl:variable>
      <xsl:variable name="BitStreamVoIPProductCode">VI203</xsl:variable>        
    
      <xsl:variable name="ProductType"> 
        <xsl:value-of select="request-param[@name='productType']"/>
      </xsl:variable>
      
      <xsl:variable name="TargetProductType"> 
        <xsl:value-of select="request-param[@name='targetProductType']"/>
      </xsl:variable>
  
      <xsl:variable name="ProductCode"> 
        <xsl:value-of select="request-param[@name='productCode']"/>
      </xsl:variable>   
      
      <xsl:variable name="TargetProductCode"> 
        <xsl:value-of select="request-param[@name='targetProductCode']"/>
      </xsl:variable>
          
      <xsl:variable name="ProductTypeBasis">Basis</xsl:variable> 
      <xsl:variable name="ProductTypePremium">Premium</xsl:variable> 
        
      <xsl:variable name="TerminationReason">AGKTW</xsl:variable> 
    
      <xsl:variable name="ReasonRd">PRODUCT_CHANGE</xsl:variable> 

      <xsl:variable name="OrderVariant">                
        <xsl:value-of select="request-param[@name='orderVariant']"/>
      </xsl:variable> 
             
      <xsl:if test="(request-param[@name='accessNumber1'] != '')                              
        and (request-param[@name='numberOfNewAccessNumbers'] != '0') 
        and ($ProductType  = '' 
            or ($ProductType  = $ProductTypePremium
                and $TargetProductType  = $ProductTypeBasis))">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers must be set to '0' if no new access numbers are ordered!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
           
      <xsl:if
        test="($TargetProductCode = $ProductCode)">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter 'targetProductCode' can't contains the same value as the paramter 'productCode' for a technology change!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
   
          
      <xsl:if
        test="($TargetProductCode != $ISDNProductCode) and 
        ($TargetProductCode != $DSLProductCode) and 
        ($TargetProductCode != $BitStreamDSLProductCode)">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_3</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Technology change only allowed for V0002 and I1204 and I1203!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
 
      <xsl:if
        test="(request-param[@name='orderVariant'] != 'Technologiewechsel') and
        (request-param[@name='orderVariant'] != 'Technologiewechsel TALBIT') ">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_4</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed value for the parameter orderVariant is: Technologiewechsel, Technologiewechsel TALBIT!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>     
      
      <xsl:if
        test="($ProductType != ''and $TargetProductType = '')
        or($ProductType = ''and $TargetProductType != '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_5</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Both Parameter ProductType and targetProducttype musst be set!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
 
 
      <xsl:if
        test="$TargetProductCode = $ISDNProductCode
        and $TargetProductType = $ProductTypeBasis
        and request-param[@name='createDSL'] != 'Y'"> 
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_6</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter 'createDSL' musst be set to 'Y' if the target product type is Basis!</xsl:element>
          </xsl:element>
        </xsl:element>  
      </xsl:if>
      
      <xsl:if
        test="($ProductType !=  '' 
        and ($ProductType != $ProductTypeBasis 
        and $ProductType != $ProductTypePremium) )
        or
        ($TargetProductType  != ''
        and ($TargetProductType != $ProductTypeBasis 
        and $TargetProductType != $ProductTypePremium))"> 
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_7</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Only 'Basis' or 'Premium' are allowed for the parameter productType or targetProductType!</xsl:element>
          </xsl:element>
        </xsl:element>  
      </xsl:if>
          
      <xsl:if test="request-param[@name='accessNumber1'] = ''                              
        and request-param[@name='numberOfNewAccessNumbers'] = '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_technology_error_9</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The access numbers to keep musst be populated numberOfNewAccessNumbers is set to '0'!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
                    
      <!-- Find service Subs for given  service subscription id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">

          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='activationDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- find directory entry stp -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_directory_entry</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="no_stp_error">N</xsl:element>
          <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0100</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get data from STP -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- cancel the service in OPM -->
      <xsl:element name="CcmFifCancelCustomerOrderCmd">
        <xsl:element name="command_id">cancel_directory_entry</xsl:element>
        <xsl:element name="CcmFifCancelCustomerOrderInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>            
          </xsl:element>
          <xsl:element name="cancel_reason_rd">UMZ</xsl:element>
          <xsl:element name="cancel_opm_order_ind">Y</xsl:element>
          <xsl:element name="skip_already_processed">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- do not raise an error if no relased STP found or if OPM order does not exists but OP internal order has been successfully rejected -->      
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_raise_error</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">[Y,N]_[Y,N,]</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_directory_entry</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">_</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">cancel_directory_entry</xsl:element>
                <xsl:element name="field_name">op_order_rejected_ind</xsl:element>							
              </xsl:element>
            </xsl:element>
          <xsl:element name="output_string_type">[Y,N]</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">Y_N</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">Y_</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- raise error to initiate functional recycling -->      
      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raise_error_func_recycle</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text">IT-22324: TBE-Stornierung in Arbeit, Request muss morgen wieder ausgeführt werden.</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_raise_error</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>
      </xsl:element>     
      
      <!-- Validate if account is owned by the customer-->
      <xsl:element name="CcmFifValidateObjectOwnerCmd">
        <xsl:element name="command_id">validate_object_owner_1</xsl:element>
        <xsl:element name="CcmFifValidateObjectOwnerInCont">
          <xsl:element name="object_type">AC</xsl:element>
          <xsl:element name="object_id">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="raise_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Remove DEACT record for purchased services if any -->
      <xsl:element name="CcmFifRemoveDeactCSCsForPurchasedServiceCmd">
        <xsl:element name="command_id">remove_deact_cscs_1</xsl:element>
        <xsl:element name="CcmFifRemoveDeactCSCsForPurchasedServiceInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!--
        Evaluate target product code
      -->
      
      <xsl:if
        test="($TargetProductCode = $ISDNProductCode)
        and ($TargetProductType = '' or $TargetProductType = $ProductType)"> 
        &ChangeTechnology_ISDN; 
      </xsl:if>

      <xsl:if
        test="($TargetProductCode = $ISDNProductCode)
        and ($ProductType = $ProductTypePremium)
        and ($TargetProductType = $ProductTypeBasis)"> 
        &DowngradeToBasis_ISDN;
      </xsl:if>
       
      <xsl:if
        test="($TargetProductCode = $ISDNProductCode)
        and ($ProductType = $ProductTypeBasis)
        and ($TargetProductType = $ProductTypePremium)"> 
        &UpgradeToPremium_ISDN; 
      </xsl:if>
      
      <xsl:if
        test="($TargetProductCode = $DSLProductCode)
        and ($TargetProductType = '' or $TargetProductType = $ProductType)"> 
        &ChangeTechnology_NGN; 
      </xsl:if>
          
      <xsl:if
        test="($TargetProductCode = $DSLProductCode)
        and ($ProductType = $ProductTypePremium)
        and ($TargetProductType = $ProductTypeBasis)"> 
        &DowngradeToBasis_NGN;
      </xsl:if>
      
      <xsl:if
        test="($TargetProductCode = $DSLProductCode)
        and ($ProductType = $ProductTypeBasis)
        and ($TargetProductType = $ProductTypePremium)"> 
        &UpgradeToPremium_NGN; 
      </xsl:if>

      <xsl:if
        test="($TargetProductCode = $BitStreamDSLProductCode)"> 
        
        <xsl:if
          test="($TargetProductType = ''  or $ProductType = $TargetProductType)"> 
          &ChangeTechnology_BitStream; 
        </xsl:if>
        
        <xsl:if
          test=" ($ProductType = $ProductTypePremium)and ($TargetProductType = $ProductTypeBasis)"> 
          &DowngradeToBasis_BitStream;   
        </xsl:if>
        
        <xsl:if
          test="($ProductType = $ProductTypeBasis)and ($TargetProductType = $ProductTypePremium)"> 
          &UpgradeToPremium_BitStream;    
        </xsl:if>
      </xsl:if>        
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
