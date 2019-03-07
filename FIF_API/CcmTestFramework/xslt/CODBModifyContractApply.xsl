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
           
      <xsl:if test="request-param[@name='isOnlySpecialTerminationRight'] != 'Y'">
          <!-- find service -->
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
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
        
          <!-- Sign Order Form And Apply New Pricing Structure -->
          <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
            <xsl:element name="command_id">sign_apply_1</xsl:element>
            <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
              <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">map_supported_object</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="supported_object_type_rd_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>
              <xsl:element name="apply_swap_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
              <xsl:element name="board_sign_name">Vodafone</xsl:element>
              <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
            </xsl:element>
          </xsl:element>
                  
          <!-- Get contract data -->
          <xsl:element name="CcmFifGetProductCommitmentDataCmd">
            <xsl:element name="command_id">get_contract_data</xsl:element>
            <xsl:element name="CcmFifGetProductCommitmentDataInCont">
              <xsl:element name="product_commitment_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>							
              </xsl:element>
              <xsl:element name="retrieve_signed_version">Y</xsl:element>
              <xsl:element name="contract_type_rd_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
    
          <!-- Contact -->
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="command_id">create_contact_1</xsl:element>
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="contact_type_rd">CONTRACT</xsl:element>
              <xsl:element name="short_description">Vertragsänderung</xsl:element>
              <xsl:element name="description_text_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>Tarifwechsel für Vertrag/Serviceschein </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">map_supported_object</xsl:element>
                  <xsl:element name="field_name">output_string</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text> wurde durchgeführt.</xsl:text>
                    <xsl:if test="request-param[@name='newPricingStructureCode'] != ''">
                      <xsl:text>&#xA;Neuer Tarif: </xsl:text>
                      <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                    </xsl:if>
                    <xsl:text>&#xA;TransactionID: </xsl:text>
                    <xsl:value-of select="request-param[@name='transactionID']"/>
                    <xsl:text>&#xA;FIF-Client: </xsl:text>
                    <xsl:value-of select="request-param[@name='clientName']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>      
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
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
