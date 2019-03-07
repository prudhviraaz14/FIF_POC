<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an apply new pricing structure FIF request
  
  @author goethalo
-->
<xsl:stylesheet 
  exclude-result-prefixes="dateutils" 
  version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
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
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
      
      <xsl:choose>
        <xsl:when test="request-param[@name='SUPPRESS_BILLING_NOTIFICATION'] = 'Y'
          and request-param[@name='NEW_PRICING_STRUCTURE'] != ''">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">illegal_parameters</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Falls der Tarif geändert wird, muss Billing benachrichtigt werden (SUPPRESS_BILLING_NOTIFICATION = N)!</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
                    
        <!-- Get contract type - contract number is mandatory  -->
		  <xsl:element name="CcmFifGetOwningCustomerCmd">
			  <xsl:element name="command_id">get_customer</xsl:element>
			  <xsl:element name="CcmFifGetOwningCustomerInCont">
				  <xsl:element name="contract_number">
  				     <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
				  </xsl:element>
			  </xsl:element>
		  </xsl:element>

        <!-- Get contract type - contract number is mandatory  -->
		  <xsl:element name="CcmFifGetContractTypeCmd">
			  <xsl:element name="command_id">get_contract_type</xsl:element>
			  <xsl:element name="CcmFifGetContractTypeInCont">
				  <xsl:element name="contract_number">
  				     <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
				  </xsl:element>
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_customer</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
			  </xsl:element>
		  </xsl:element>


          <!-- Renegotiate Order Form  -->
          <xsl:element name="CcmFifRenegotiateOrderFormCmd">
            <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
            <xsl:element name="CcmFifRenegotiateOrderFormInCont">
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
              </xsl:element>
              <xsl:element name="loi_indicator">
                <xsl:value-of select="request-param[@name='LOI_INDICATOR']"/>
              </xsl:element>
              <xsl:element name="notice_per_dur_value">
                <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_VALUE']"/>
              </xsl:element>
              <xsl:element name="notice_per_dur_unit">
                <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_UNIT']"/>
              </xsl:element>     
              <xsl:element name="min_per_dur_value">
                <xsl:value-of select="request-param[@name='MIN_PER_DUR_VALUE']"/>
              </xsl:element>     
              <xsl:element name="min_per_dur_unit">
                <xsl:value-of select="request-param[@name='MIN_PER_DUR_UNIT']"/>
              </xsl:element>     
              <xsl:element name="term_start_date">
                <xsl:value-of select="request-param[@name='TERM_START_DATE']"/>
              </xsl:element>     
              <xsl:element name="monthly_order_entry_amount">
                <xsl:value-of select="request-param[@name='MONTHLY_ORDER_ENTRY_AMOUNT']"/>
              </xsl:element>     
              <xsl:element name="termination_restriction">
                <xsl:value-of select="request-param[@name='TERMINATION_RESTRICTION']"/>
              </xsl:element>     
              <xsl:element name="doc_template_name">
                <xsl:value-of select="request-param[@name='DOC_TEMPLATE_NAME']"/>
              </xsl:element>          
              <xsl:element name="assoc_skeleton_cont_num">
                <xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONT_NUM']"/>
              </xsl:element>     
              <xsl:element name="override_restriction">
                <xsl:value-of select="request-param[@name='OVERRIDE_RESTRICTION']"/>
              </xsl:element>               
              <xsl:if test="request-param[@name='NEW_PRICING_STRUCTURE'] != ''">
                <xsl:element name="product_commit_list">
                  <xsl:element name="CcmFifProductCommitCont">
                    <xsl:element name="new_pricing_structure_code">
                      <xsl:value-of select="request-param[@name='NEW_PRICING_STRUCTURE']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:element name="min_period_start_date">
                <xsl:value-of select="request-param[@name='MIN_PERIOD_START_DATE']"/>
              </xsl:element>                         
              <xsl:element name="auto_extent_period_value">
                <xsl:value-of select="request-param[@name='AUTO_EXTENT_PERIOD_VALUE']"/>
              </xsl:element>                         
              <xsl:element name="auto_extent_period_unit">
                <xsl:value-of select="request-param[@name='AUTO_EXTENT_PERIOD_UNIT']"/>
              </xsl:element>                         
              <xsl:element name="auto_extension_ind">
                <xsl:value-of select="request-param[@name='AUTO_EXTENSION_IND']"/>
              </xsl:element>    
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_contract_type</xsl:element>
						<xsl:element name="field_name">contract_type_rd</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">O</xsl:element>										
              <xsl:element name="contract_name">
                <xsl:value-of select="request-param[@name='CONTRACT_NAME']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- Sign and Apply No PC -->
          <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
            <xsl:element name="command_id">sign_apply_1</xsl:element>
            <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
              <xsl:element name="supported_object_id">
                <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
              </xsl:element>
					<xsl:element name="supported_object_type_rd">O</xsl:element>
              <xsl:element name="apply_swap_date">
                <xsl:value-of select="request-param[@name='APPLY_DATE']"/>
              </xsl:element>
              <xsl:element name="board_sign_name">
                <xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
              </xsl:element>     
              <xsl:element name="board_sign_date">
                <xsl:value-of select="request-param[@name='BOARD_SIGN_DATE']"/>
              </xsl:element>     
              <xsl:element name="primary_cust_sign_name">
                <xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_NAME']"/>
              </xsl:element>     
              <xsl:element name="primary_cust_sign_date">
                <xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_DATE']"/>
              </xsl:element>     
              <xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_contract_type</xsl:element>
						<xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>          
              <xsl:element name="required_process_ind">O</xsl:element>          
              <xsl:element name="rcp_notif_blocking_ind">
                <xsl:value-of select="request-param[@name='SUPPRESS_BILLING_NOTIFICATION']"/>
              </xsl:element>                
            </xsl:element>
          </xsl:element>                   
          
          <!-- Renegotiate SDCPC  -->
          <xsl:element name="CcmFifRenegotiateSDCProductCommitmentCmd">
            <xsl:element name="command_id">renegotiate_sdcpc</xsl:element>
            <xsl:element name="CcmFifRenegotiateSDCProductCommitmentInCont">
              <xsl:element name="product_commitment_number">
  				    <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
              </xsl:element>
              <xsl:element name="loi_indicator">
                <xsl:value-of select="request-param[@name='LOI_INDICATOR']"/>
              </xsl:element>
              <xsl:element name="notice_per_dur_value">
                <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_VALUE']"/>
              </xsl:element>
              <xsl:element name="notice_per_dur_unit">
                <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_UNIT']"/>
              </xsl:element>     
              <xsl:element name="term_start_date">
                <xsl:value-of select="request-param[@name='TERM_START_DATE']"/>
              </xsl:element>
              <xsl:element name="monthly_order_entry_amount">
                <xsl:value-of select="request-param[@name='MONTHLY_ORDER_ENTRY_AMOUNT']"/>
              </xsl:element>     
              <xsl:element name="termination_restriction">
                <xsl:value-of select="request-param[@name='TERMINATION_RESTRICTION']"/>
              </xsl:element>     
              <xsl:element name="doc_template_name">
                <xsl:value-of select="request-param[@name='DOC_TEMPLATE_NAME']"/>
              </xsl:element>          
              <xsl:element name="assoc_skeleton_cont_num">
                <xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONT_NUM']"/>
              </xsl:element>     
              <xsl:element name="override_restriction">
                <xsl:value-of select="request-param[@name='OVERRIDE_RESTRICTION']"/>
              </xsl:element>               
              <xsl:if test="request-param[@name='NEW_PRICING_STRUCTURE'] != '' or
                request-param[@name='MIN_PER_DUR_VALUE'] != '' or
                request-param[@name='MIN_PER_DUR_UNIT'] != ''" >
                <xsl:element name="product_commit_list">
                  <xsl:element name="CcmFifProductCommitCont">
                    <xsl:element name="new_pricing_structure_code">
                      <xsl:value-of select="request-param[@name='NEW_PRICING_STRUCTURE']"/>
                    </xsl:element>
                    <xsl:element name="min_per_dur_value">
                      <xsl:value-of select="request-param[@name='MIN_PER_DUR_VALUE']"/>
                    </xsl:element>
                    <xsl:element name="min_per_dur_unit">
                      <xsl:value-of select="request-param[@name='MIN_PER_DUR_UNIT']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:element name="auto_extent_period_value">
                <xsl:value-of select="request-param[@name='AUTO_EXTENT_PERIOD_VALUE']"/>
              </xsl:element>                         
              <xsl:element name="auto_extent_period_unit">
                <xsl:value-of select="request-param[@name='AUTO_EXTENT_PERIOD_UNIT']"/>
              </xsl:element>                         
              <xsl:element name="auto_extension_ind">
                <xsl:value-of select="request-param[@name='AUTO_EXTENSION_IND']"/>
              </xsl:element>  
              <xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_contract_type</xsl:element>
						<xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>          
              <xsl:element name="required_process_ind">S</xsl:element>          
            </xsl:element>
          </xsl:element>      
        
          <!-- Sign and Apply SDCPC -->
          <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
            <xsl:element name="command_id">sign_apply_1</xsl:element>
            <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
              <xsl:element name="supported_object_id">
                <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
              </xsl:element>
					<xsl:element name="supported_object_type_rd">S</xsl:element>
              <xsl:element name="apply_swap_date">
                <xsl:value-of select="request-param[@name='APPLY_DATE']"/>
              </xsl:element>
              <xsl:element name="board_sign_name">
                <xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
              </xsl:element>     
              <xsl:element name="board_sign_date">
                <xsl:value-of select="request-param[@name='BOARD_SIGN_DATE']"/>
              </xsl:element>     
              <xsl:element name="primary_cust_sign_name">
                <xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_NAME']"/>
              </xsl:element>     
              <xsl:element name="primary_cust_sign_date">
                <xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_DATE']"/>
              </xsl:element>     
              <xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_contract_type</xsl:element>
						<xsl:element name="field_name">contract_type_rd</xsl:element>
              </xsl:element>          
              <xsl:element name="required_process_ind">S</xsl:element>          
              <xsl:element name="rcp_notif_blocking_ind">
                <xsl:value-of select="request-param[@name='SUPPRESS_BILLING_NOTIFICATION']"/>
              </xsl:element>                
            </xsl:element>
          </xsl:element>                   
          
          <xsl:if test="request-param[@name='CREATE_CCM_CONTACT'] = 'Y'
            or request-param[@name='CREATE_KBA_CONTACT'] = 'Y'">
            
            <xsl:element name="CcmFifGetOwningCustomerCmd">
              <xsl:element name="command_id">get_owning_customer</xsl:element>
              <xsl:element name="CcmFifGetOwningCustomerInCont">
                <xsl:element name="contract_number">
                  <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <xsl:variable name="contactText">
              <xsl:text>Daten für Vertrag </xsl:text>
              <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
              <xsl:if test="request-param[@name='PRODUCT_COMMITMENT_NUMBER'] != ''">
                <xsl:text> und Serviceschein </xsl:text>
                <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
              </xsl:if>
              <xsl:text> geändert mit SLS-FIF-Transaktion </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>.</xsl:text>            
              <xsl:if test="request-param[@name='LONG_DESCRIPTION_TEXT'] != ''">
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
              </xsl:if>
            </xsl:variable>
            
            <xsl:if test="request-param[@name='CREATE_CCM_CONTACT'] = 'Y'">
              <!-- Create Contact -->
              <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="CcmFifCreateContactInCont">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">get_owning_customer</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="contact_type_rd">
                    <xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
                  </xsl:element>
                  <xsl:element name="short_description">
                    <xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
                  </xsl:element>
                  <xsl:element name="long_description_text">
                    <xsl:value-of select="$contactText"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='CREATE_KBA_CONTACT'] = 'Y'">
              <!-- Create KBA notification  -->
              <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <!-- Get today's date -->
                <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
                <xsl:element name="command_id">create_kba_notification_1</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                  <xsl:element name="effective_date">
                    <xsl:value-of select="$today"/>
                  </xsl:element>                
                  <xsl:element name="notification_action_name">createKBANotification</xsl:element>
                  <xsl:element name="target_system">KBA</xsl:element>
                  <xsl:element name="parameter_value_list">
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                      <xsl:element name="parameter_value_ref">
                        <xsl:element name="command_id">get_owning_customer</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">TYPE</xsl:element>
                      <xsl:element name="parameter_value">CONTACT</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">CATEGORY</xsl:element>
                      <xsl:element name="parameter_value">Tariff</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">USER_NAME</xsl:element>
                      <xsl:element name="parameter_value">SLS-Clearing</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="$today"/>
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
            </xsl:if>
          </xsl:if>
          
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
