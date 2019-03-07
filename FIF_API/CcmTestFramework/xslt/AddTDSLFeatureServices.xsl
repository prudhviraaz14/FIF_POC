<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for converting an OPM change TDSL Provider request
  to a FIF transaction

  @author makuier
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    exclude-result-prefixes="dateutils">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
    <!-- Transaction ID -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">OPM</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Convert the termination date to OPM format -->
      <xsl:variable name="activationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='DESIRED_DATE'])"/>
      <!-- Generate a FIF date that is one day after the desired date -->
      <xsl:variable name="desiredDatePlusOne"
        select="dateutils:createFIFDateOffset(request-param[@name='DESIRED_DATE'], 'DATE', '1')"/>
	  
      <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 16000'
        and request-param[@name='FASTPATH_FLAG'] = 'Y'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">fastpath_flag_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter FASTPATH_FLAG can not be set for the bandwith DSL 16000.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
     
      <!-- Ensure that either ACCESS_NUMBER or  SERVICE_SUBSCRIPTION_ID are provided -->
      <xsl:if test="(request-param[@name='ACCESS_NUMBER'] = '') and
        (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
        
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">find_ss_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">At least SERVICE_SUBSCRIPTION_ID or ACCESS_NUMBER must be provided!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Find Service Subscription by access number,or service_subscription id  if no bundle was found -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="((request-param[@name='ACCESS_NUMBER'] != '' )and ((request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')))">
            <xsl:element name="access_number">
              <xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
            </xsl:element>
            <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
            <xsl:element name="contract_number">
              <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
            </xsl:element>
            <xsl:element name="technical_service_code">TOC_NONBILL</xsl:element>              
          </xsl:if>
          <xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>
              
      <!-- Find Service Subscription for Arcor Online -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_2</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1040</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate Product Subscription Count -->
      <xsl:element name="CcmFifValidateProdSubsCountCmd">
        <xsl:element name="command_id">valid_ps_count_1</xsl:element>
        <xsl:element name="CcmFifValidateProdSubsCountInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Actions to perform when changing the tariff or the minimum duration -->
      <xsl:if test="(request-param[@name='CHANGE_TARIFF'] = 'Y') 
		or (request-param[@name='CHANGE_MINIMUM_DURATION'] = 'Y')">
        <!-- Renegotiate Order Form  -->
        <xsl:element name="CcmFifRenegotiateOrderFormCmd">
          <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
          <xsl:element name="CcmFifRenegotiateOrderFormInCont">
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
			<xsl:if test="(request-param[@name='CHANGE_MINIMUM_DURATION'] = 'Y')"> 			             
              <xsl:element name="min_per_dur_value">
                <xsl:value-of select="request-param[@name='MINIMUM_DURATION']"/>
              </xsl:element>
			  <xsl:element name="term_start_date">
			    <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
			  </xsl:element>			  
			</xsl:if>
            <xsl:element name="override_restriction">Y</xsl:element>  
			<xsl:if test="(request-param[@name='CHANGE_TARIFF'] = 'Y')"> 			             
              <xsl:element name="product_commit_list">
                <xsl:element name="CcmFifProductCommitCont">
                  <xsl:element name="new_pricing_structure_code">
                    <xsl:value-of select="request-param[@name='NEW_TARIFF']"/>
                  </xsl:element>   
                </xsl:element>
              </xsl:element>
			</xsl:if>
            <xsl:if test="request-param[@name='SPECIAL_TERM_RIGHT'] != ''">
              <xsl:element name="special_termination_right">
                <xsl:value-of select="request-param[@name='SPECIAL_TERM_RIGHT']"/>
              </xsl:element>                         
            </xsl:if>
          </xsl:element>
        </xsl:element> 
        <!-- Sign Order Form -->
        <xsl:element name="CcmFifSignOrderFormCmd">
          <xsl:element name="command_id">sign_order_form_1</xsl:element>
          <xsl:element name="CcmFifSignOrderFormInCont">
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="board_sign_name">ARCOR</xsl:element>
            <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Apply New Pricing Structure -->
        <xsl:element name="CcmFifApplyNewPricingStructCmd">
          <xsl:element name="command_id">apply_new_ps_1</xsl:element>
          <xsl:element name="CcmFifApplyNewPricingStructInCont">
            <xsl:element name="supported_object_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">O</xsl:element>
            <xsl:element name="apply_swap_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Renegotiate main access service contract when special termination right is provided -->
      <xsl:if test="request-param[@name='SPECIAL_TERM_RIGHT'] != ''
        and (request-param[@name='SPECIAL_TERM_RIGHT'] != 'NONE')">
        
        <xsl:if test="(request-param[@name='CHANGE_TARIFF'] != 'Y') 
          and (request-param[@name='CHANGE_MINIMUM_DURATION'] != 'Y')">
          <xsl:element name="CcmFifRenegotiateOrderFormCmd">
            <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
            <xsl:element name="CcmFifRenegotiateOrderFormInCont">
              <xsl:element name="contract_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
              <xsl:element name="special_termination_right">
                <xsl:value-of select="request-param[@name='SPECIAL_TERM_RIGHT']"/>
              </xsl:element>                         
            </xsl:element>
          </xsl:element> 
          
          <!-- Sign Order Form -->
          <xsl:element name="CcmFifSignOrderFormCmd">
            <xsl:element name="command_id">sign_order_form_1</xsl:element>
            <xsl:element name="CcmFifSignOrderFormInCont">
              <xsl:element name="contract_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
              <xsl:element name="board_sign_name">ARCOR</xsl:element>
              <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
        <!-- Create CSECOMMENT for the  -->
        <xsl:if test="(request-param[@name='SPECIAL_TERM_RIGHT'] != 'NONE')
          and (request-param[@name='SPECIAL_TERM_DESC'] != '')">
          <!-- Create Comment -->
          <xsl:element name="CcmFifCreateCommentCmd">
            <xsl:element name="command_id">create_comment_1</xsl:element>
            <xsl:element name="CcmFifCreateCommentInCont">
              <xsl:element name="comment_id_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="comment_type_rd">Med</xsl:element>
              <xsl:element name="short_description">SPECIAL TERMINATION RIGHT</xsl:element>
              <xsl:element name="long_description_text">
                <xsl:value-of select="request-param[@name='SPECIAL_TERM_DESC']"/>
              </xsl:element>
              <xsl:element name="object_type">SS</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
      </xsl:if>

      <!-- Actions to perform when only the upstream bandwidth changes -->
      <xsl:if test="(request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'Y') and (request-param[@name='CHANGE_BANDWIDTH'] != 'Y')">
        <!-- Find the exclusive child service subscription for Arcor Online service -->
        <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
          <xsl:element name="command_id">find_excl_child_1</xsl:element>
          <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code_list">
			  <!-- DSL 1500 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0117</xsl:element>
              </xsl:element>
			  <!-- DSL 1000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0118</xsl:element>
              </xsl:element>
			  <!-- DSL 2000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0174</xsl:element>
              </xsl:element>
			  <!-- DSL 3000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0175</xsl:element>
              </xsl:element>
			  <!-- DSL 6000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0178</xsl:element>
              </xsl:element>	
              <!-- DSL 16000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V018C</xsl:element>
              </xsl:element>              		  
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Terminate Upstream DSL Services -->
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_ss_1</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_excl_child_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
            <xsl:element name="service_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0196</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0197</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0198</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0199</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Actions to perform when the downstream bandwidth changes -->
      <xsl:if test="request-param[@name='CHANGE_BANDWIDTH'] = 'Y'">
        <!-- Terminate DSL bandwidth services -->
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_ss_2</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
            <xsl:element name="service_code_list">
			  <!-- DSL 384 -->
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0133</xsl:element>
              </xsl:element>
			  <!-- DSL 768 -->
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0116</xsl:element>
              </xsl:element>	
			  <!-- DSL 1500 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0117</xsl:element>
              </xsl:element>
			  <!-- DSL 1000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0118</xsl:element>
              </xsl:element>
			  <!-- DSL 2000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0174</xsl:element>
              </xsl:element>
			  <!-- DSL 3000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0175</xsl:element>
              </xsl:element>
			  <!-- DSL 6000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0178</xsl:element>
              </xsl:element>
              <!-- DSL 16000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V018C</xsl:element>
              </xsl:element>  			  
            </xsl:element>
          </xsl:element>
        </xsl:element>
		
        <!-- Find stp for the reconfigured DSL-R service -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_stp_1</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="usage_mode_value_rd">2</xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Get the salesOrgNumber in parent service's CSC V0990 -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_csc_value_1</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0990</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Add New DSL Bandwidth Service -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 1000'">
              <xsl:element name="service_code">V0118</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 1500'">
              <xsl:element name="service_code">V0117</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 2000'">
              <xsl:element name="service_code">V0174</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 3000'">
              <xsl:element name="service_code">V0175</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 6000'">
              <xsl:element name="service_code">V0178</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='BANDWIDTH'] = 'DSL 16000'">
              <xsl:element name="service_code">V018C</xsl:element>
            </xsl:if>  			
            <xsl:element name="sales_organisation_number_ref">
              <xsl:element name="command_id">find_csc_value_1</xsl:element>
              <xsl:element name="field_name">characteristic_value</xsl:element>
            </xsl:element>  
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$desiredDatePlusOne"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
			<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''"> 			             
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
            </xsl:if>
			<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''"> 			             
              <xsl:element name="account_number">
              	<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
              </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Actions to perform when the upstream bandwidth is changing -->      
      <xsl:if test="request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'Y'
             and request-param[@name='UPSTREAM_BANDWIDTH'] != 'Standard'">
        <!-- Add New Upstream DSL Bandwidth Service -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='UPSTREAM_BANDWIDTH'] = '256'
                   and request-param[@name='BANDWIDTH'] = 'DSL 1000'">
              <xsl:element name="service_code">V0196</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='UPSTREAM_BANDWIDTH'] = '384'
                   and request-param[@name='BANDWIDTH'] = 'DSL 1500'">
              <xsl:element name="service_code">V0197</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='UPSTREAM_BANDWIDTH'] = '384'
                   and request-param[@name='BANDWIDTH'] = 'DSL 2000'">
              <xsl:element name="service_code">V0198</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='UPSTREAM_BANDWIDTH'] = '512'">
              <xsl:element name="service_code">V0199</xsl:element>
            </xsl:if>
            <xsl:element name="parent_service_subs_ref">
              <xsl:if test="request-param[@name='CHANGE_BANDWIDTH'] = 'Y'">
                <xsl:element name="command_id">add_service_1</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='CHANGE_BANDWIDTH'] != 'Y'">
                <xsl:element name="command_id">find_excl_child_1</xsl:element>
              </xsl:if>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$desiredDatePlusOne"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
			<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''"> 			             
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
            </xsl:if>
			<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''"> 			             
              <xsl:element name="account_number">
              	<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
              </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

	  <!-- Actions to perform when Fastpath is changing -->
      <xsl:if test="(request-param[@name='CHANGE_FASTPATH'] = 'Y')
              or (request-param[@name='BANDWIDTH'] = 'DSL 16000')">
		<!-- Terminate Fastpath Service -->
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_ss_3</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
            <xsl:element name="service_code_list">
			  <!-- Fastpath -->
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1045</xsl:element>
              </xsl:element>                                    
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
		<!-- Add Fastpath Service, if needed -->
        <xsl:if test="(request-param[@name='FASTPATH_FLAG'] = 'Y')">
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_3</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">I1045</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_service_2</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$desiredDatePlusOne"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
		      <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''"> 			             
                <xsl:element name="account_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">account_number</xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''"> 			             
                <xsl:element name="account_number">
                  <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
                </xsl:element>
              </xsl:if>
              <xsl:element name="service_characteristic_list">
              </xsl:element>
            </xsl:element>
          </xsl:element>
		</xsl:if>
	  </xsl:if>	  
   
      <!-- Add feature service Service, if needed -->
      <xsl:if test="request-param[@name='ADD_FEATURE_SERVICE'] = 'Y'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_4</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">
				<xsl:value-of select="request-param[@name='FEATURE_SERVICE_CODE']"/>
            </xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$desiredDatePlusOne"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
			<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''"> 			             
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
            </xsl:if>
			<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''"> 			             
              <xsl:element name="account_number">
              	<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
              </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Create Customer Order for terminations -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
		  <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_ss_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_ss_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>			
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_ss_3</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>			
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for new services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parent_customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>	
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_3</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_4</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>									
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order for Terminations -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
		  <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
	  
      <!-- Release Customer Order for new services -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
	  
      <!-- Create Contact for the feature change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">DSL_R_CHANGE</xsl:element>
          <xsl:element name="short_description">Änderung Leistungsmerkmal DSLR</xsl:element>
          <xsl:element name="description_text_list">
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>Source: OPM (Lieferung)</xsl:text>
				  <!-- Only Downstream change -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] != 'Y')
								and (request-param[@name='CHANGE_TARIFF'] != 'Y')">
				    <xsl:text>&#xA;GF: Bandbreitenwechsel</xsl:text>
				  </xsl:if>
				  <!-- Downstream and Upstream change -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_TARIFF'] != 'Y')">
				    <xsl:text>&#xA;GF: BBW-/Upstreamwechsel</xsl:text>
				  </xsl:if>
				  <!-- Downstream and tariff change -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'N')
								and (request-param[@name='CHANGE_TARIFF'] = 'Y')">
				    <xsl:text>&#xA;GF: BBW-/Tarifwechsel</xsl:text>
				  </xsl:if>				  
				  <!-- Downstream, Upstream, Tariff change -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_TARIFF'] = 'Y')">
				    <xsl:text>&#xA;GF: BBW-/Upstream-/Tarifwechsel</xsl:text>
				  </xsl:if>
				  <!-- Only Upstream -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] != 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_TARIFF'] != 'Y')">
				    <xsl:text>&#xA;GF: Upstreamwechsel</xsl:text>
				  </xsl:if>
				  <!-- Upstream and Tariff change -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] != 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] = 'Y')
								and (request-param[@name='CHANGE_TARIFF'] = 'Y')">
				    <xsl:text>&#xA;GF: Upstream-/Tarifwechsel</xsl:text>
				  </xsl:if>
				  <!-- Only FastPath -->
				  <xsl:if test="(request-param[@name='CHANGE_BANDWIDTH'] != 'Y')
								and (request-param[@name='CHANGE_UPSTREAM_BANDWIDTH'] != 'Y')
								and (request-param[@name='CHANGE_FASTPATH'] = 'Y')">
				    <xsl:text>&#xA;GF: Fastpath-Änderung</xsl:text>
				  </xsl:if>
                  <xsl:text>&#xA;ProductSubscriptionNumber: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>&#xA;ContractNumber: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
