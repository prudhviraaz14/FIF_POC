<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Modify Contract FIF request

  @author goethalo
-->
<!DOCTYPE XSL [
<!ENTITY ModifyContract_Mobile SYSTEM "ModifyContract_Mobile.xsl">
<!ENTITY ModifyContract_Default SYSTEM "ModifyContract_Default.xsl">
]>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction_list.dtd" encoding="ISO-8859-1" indent="yes"
    method="xml"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifTransactionList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="request-params">
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_list_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="transaction_list_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:if test="request-param[@name='clientName'] != ''">      
      <xsl:element name="transaction_list_client_name">
        <xsl:value-of select="request-param[@name='clientName']"/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="intermediate_transaction_list">Y</xsl:element>
    <xsl:element name="transaction_list"> 

      <xsl:element name="CcmFifCommandList">
        <xsl:element name="transaction_id">
          <xsl:value-of select="request-param[@name='transactionID']"/>
        </xsl:element>
        <xsl:element name="client_name">
          <xsl:value-of select="request-param[@name='clientName']"/>
        </xsl:element>
        <xsl:variable name="TopAction" select="//request/action-name"/>
        <xsl:element name="action_name">
          <xsl:value-of select="concat($TopAction, '_DM')"/>
        </xsl:element>   
        <xsl:element name="override_system_date">
          <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
        </xsl:element>
        <xsl:element name="decision_maker_list">Y</xsl:element>
        <xsl:element name="Command_List">
          
          <!-- Get Order Form Data for APPROVED row -->
          <xsl:element name="CcmFifGetOrderFormDataCmd">
            <xsl:element name="command_id">get_order_form_data_0_approved</xsl:element>
            <xsl:element name="CcmFifGetOrderFormDataInCont">
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='contractNumber']"/>
              </xsl:element>
              <xsl:element name="target_state">APPROVED</xsl:element>
              <xsl:element name="ignore_not_exists">Y</xsl:element>
              <xsl:element name="most_effective">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- cancel order form version -->
          <xsl:element name="CcmFifTransitionLegalAgreementCmd">
            <xsl:element name="command_id">transition_la_0</xsl:element>
            <xsl:element name="CcmFifTransitionLegalAgreementInCont">
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='contractNumber']"/>
              </xsl:element>
              <xsl:element name="state_rd">CANCELED</xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">get_order_form_data_0_approved</xsl:element>
                <xsl:element name="field_name">record_found</xsl:element>          	
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>              
            </xsl:element>
          </xsl:element>
          
          
          
          <!-- Get Order Form Data for CREATED row -->
          <xsl:element name="CcmFifGetOrderFormDataCmd">
            <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
            <xsl:element name="CcmFifGetOrderFormDataInCont">
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='contractNumber']"/>
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
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='contractNumber']"/>
              </xsl:element>
              <xsl:element name="state_rd">CANCELED</xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
                <xsl:element name="field_name">record_found</xsl:element>          	
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          
          
          
          
          <!-- Get Order Form Data -->
          <xsl:element name="CcmFifGetOrderFormDataCmd">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="CcmFifGetOrderFormDataInCont">
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='contractNumber']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <!-- Validate Get Old Price Plan Code -->
          <xsl:element name="CcmFifGetProdCommitContCmd">
            <xsl:element name="command_id">get_product</xsl:element>
            <xsl:element name="CcmFifGetProdCommitContInCont">
              <xsl:element name="prod_commit_ref">
                <xsl:element name="command_id">get_order_form_data_1</xsl:element> 
                <xsl:element name="field_name">product_commit_list</xsl:element> 
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:element name="CcmFifDecisionMakerCmd">
            <xsl:element name="command_id">decision_maker</xsl:element>
            <xsl:element name="CcmFifDecisionMakerInCont">
              <xsl:element name="value_ref">
                <xsl:element name="command_id">get_product</xsl:element>
                <xsl:element name="field_name">product_code</xsl:element>
              </xsl:element>
              <xsl:element name="decision_maker_mapping_list">
                <xsl:element name="CcmFifDecisionMakerMappingCont">
                  <xsl:element name="value">V8000</xsl:element>
                  <xsl:element name="target_action_ending">_Mobile</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifDecisionMakerMappingCont">
                  <xsl:element name="value"></xsl:element>
                  <xsl:element name="target_action_ending">_Default</xsl:element>
                </xsl:element>    			
              </xsl:element>    			
            </xsl:element>
          </xsl:element>
          
        </xsl:element> 
      </xsl:element>      
      
      &ModifyContract_Mobile;
      &ModifyContract_Default;
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
