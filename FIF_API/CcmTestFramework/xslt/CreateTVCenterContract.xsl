<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a multi media contract (TV Center Stand Alone)

  @author banania
-->

<!DOCTYPE XSL [

<!ENTITY CreateTVCenterContract_bundled SYSTEM "CreateTVCenterContract_bundled.xsl">
<!ENTITY CreateTVCenter_standalone SYSTEM "CreateTVCenter_standalone.xsl">
<!ENTITY HandleHDOptionsForSLS SYSTEM "HandleHDOptionsForSLS.xsl">

]>

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
 
      <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>

      <xsl:variable name="PosReasonRd">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='reasonRd']"/>
      </xsl:variable>

      <xsl:variable name="ReasonRd">
        <xsl:choose>
          <xsl:when test ="$PosReasonRd != ''">
            <xsl:value-of select="request-param[@name='reasonRd']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="request-param[@name='multimediaType'] = 'TV_CENTER_SA'">
              <xsl:text>ADD_TV_CENTER_SA</xsl:text>
            </xsl:if>
            <xsl:if test="request-param[@name='multimediaType'] = 'TV_CENTER'">
              <xsl:text>ADD_TV_CENTER</xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
 
      <!--Get Customer Number if not provided-->
      <xsl:if test="(request-param[@name='customerNumber'] = '')">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_1</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!--Get Account Number if not provided-->
      <xsl:if test="(request-param[@name='accountNumber'] = '')">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_2</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Get Entity Information -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity_1</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
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
        </xsl:element>
      </xsl:element>
      
      <!-- Create Location Address  if the address id is not provided.-->
      <xsl:if test="request-param[@name='addressId'] = ''">
      <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_addr_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>       
          <xsl:element name="address_type">LOKA</xsl:element>
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
          <xsl:element name="country_code">DE</xsl:element>
          <xsl:element name="ignore_existing_address">Y</xsl:element>
        </xsl:element>        
      </xsl:element>
      </xsl:if>

      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
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
          <xsl:element name="termination_restriction">
            <xsl:value-of select="request-param[@name='terminationRestriction']"/>
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
      
      <xsl:if test="request-param[@name='multimediaType'] = 'TV_CENTER'">
        &CreateTVCenterContract_bundled;
        <xsl:if test="request-param[@name='clientName'] != 'CODB' 
          and request-param[@name='clientName'] != 'POS'"> 
          &HandleHDOptionsForSLS;
        </xsl:if>
      </xsl:if>
      
      <xsl:if test="request-param[@name='multimediaType'] = 'TV_CENTER_SA'">
        &CreateTVCenter_standalone;
      </xsl:if>
      
      <xsl:if test="request-param[@name='clientName'] = 'CODB'">
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
        
        <xsl:if test="request-param[@name='manualRollback'] = 'N'">
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">TVCenterService</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">add_service_1</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>      
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">TVCenterContractNumber</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">create_order_form_1</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>      
          
        </xsl:if>          
      </xsl:if>                  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
