<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated Change Bandwidth FIF request

  @author makuier
-->
<xsl:element name="CcmFifCommandList">

  <!-- Copy over transaction ID and action name -->
  <xsl:element name="transaction_id">
    <xsl:value-of select="request-param[@name='transactionID']"/>
  </xsl:element>
  <xsl:element name="client_name">OPM</xsl:element>
  <xsl:variable name="TopAction" select="//request/action-name"/>
  <xsl:element name="action_name">
    <xsl:value-of select="concat($TopAction, '_ISDN')"/>
  </xsl:element>
  <xsl:element name="override_system_date">
    <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
  </xsl:element>
  <xsl:element name="Command_List">
      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="desiredDateOPM"
        select="dateutils:createOPMDate(request-param[@name='DESIRED_DATE'])"/>
      <!-- Calculate today and one day before the desired date -->
      <xsl:variable name="today"
          select="dateutils:getCurrentDate()"/>
      <xsl:variable name="tomorrow"
          select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
      <xsl:variable name="dayAfterTomorrow"
          select="dateutils:createFIFDateOffset($tomorrow, 'DATE', '1')"/>
      <xsl:variable name="oldBandwidthTerminationDate"
          select="dateutils:createFIFDateOffset(request-param[@name='DESIRED_DATE'], 'DATE', '-1')"/>
      <xsl:variable name="dayAfterDesiredDate"
          select="dateutils:createFIFDateOffset(request-param[@name='DESIRED_DATE'], 'DATE', '1')"/>

      <!-- Find Service Subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Lock product subscription  -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">PROD_SUBS</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find if the main access service is ISDN -->
      <xsl:element name="CcmFifValidateSCValueCmd">
        <xsl:element name="command_id">validate_service_code</xsl:element>
        <xsl:element name="CcmFifValidateSCValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>          
            <xsl:element name="field_name">service_code</xsl:element>            
          </xsl:element>      
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
			  <xsl:element name="value">V0003</xsl:element>
			</xsl:element>                    
            <xsl:element name="CcmFifPassingValueCont">
			  <xsl:element name="value">V0010</xsl:element>
			</xsl:element>                    
            <xsl:element name="CcmFifPassingValueCont">
			  <xsl:element name="value">V0011</xsl:element>
			</xsl:element>                    
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate the service subscription state -->
      <!-- validate only if ISDN -->
      <xsl:element name="CcmFifValidateServiceSubsStateCmd">
        <xsl:element name="command_id">validate_ss_state_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceSubsStateInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_state">SUBSCRIBED</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate only one service subscription for DSL service exists for ISDN scenario-->
      <xsl:element name="CcmFifValidateOnlyOneServiceExistCmd">
        <xsl:element name="command_id">validate_no_ss_1</xsl:element>
        <xsl:element name="CcmFifValidateOnlyOneServiceExistInCont">
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
          </xsl:element>     
        </xsl:element>
      </xsl:element>

      <!-- Validate no uncomplete STPs for ISDN scenario-->
      <xsl:element name="CcmFifValidateNoUncompleteStpCmd">
        <xsl:element name="command_id">validate_no_uncomplete_stp_1</xsl:element>
        <xsl:element name="CcmFifValidateNoUncompleteStpInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
          </xsl:element>      
        </xsl:element>
      </xsl:element>

      <!-- Validate that the accounts are active  -->
      <xsl:element name="CcmFifValidateServiceAccountCmd">
        <xsl:element name="command_id">validate_ss_account_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceAccountInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Renegotiate main access service contract when special termination right is provided -->
      <xsl:if test="(request-param[@name='SPECIAL_TERM_RIGHT'] != '')
        and (request-param[@name='SPECIAL_TERM_RIGHT'] != 'NONE')">
        
        <xsl:element name="CcmFifRenegotiateOrderFormCmd">
          <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
          <xsl:element name="CcmFifRenegotiateOrderFormInCont">
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>          
            <xsl:element name="special_termination_right">
              <xsl:value-of select="request-param[@name='SPECIAL_TERM_RIGHT']"/>
            </xsl:element>         
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
            </xsl:element>            
            <xsl:element name="required_process_ind">O</xsl:element>          
          </xsl:element>
        </xsl:element> 

        <!-- get SDCPC  -->
        <xsl:element name="CcmFifGetProductCommitmentDataCmd">
          <xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
          <xsl:element name="CcmFifGetProductCommitmentDataInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Renegotiate SDCPC  -->
        <xsl:element name="CcmFifRenegotiateSDCProductCommitmentCmd">
          <xsl:element name="command_id">renegotiate_sdc_1</xsl:element>
          <xsl:element name="CcmFifRenegotiateSDCProductCommitmentInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
            <xsl:element name="product_commit_list_ref">
              <xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
              <xsl:element name="field_name">product_commit_list</xsl:element>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
            </xsl:element>
            <xsl:element name="special_termination_right">
              <xsl:value-of select="request-param[@name='SPECIAL_TERM_RIGHT']"/>
            </xsl:element>                         
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>          
            <xsl:element name="required_process_ind">S</xsl:element>          
          </xsl:element>
        </xsl:element>      

        <!-- Sign Order Form -->
        <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
          <xsl:element name="command_id">sign_order_form_1</xsl:element>
          <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
            <xsl:element name="supported_object_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">O</xsl:element>
            <xsl:element name="apply_swap_date">
              <xsl:value-of select="$dayAfterDesiredDate"/>
            </xsl:element>
            <xsl:element name="board_sign_name">ARCOR</xsl:element>
            <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>          
            <xsl:element name="required_process_ind">O</xsl:element>          
          </xsl:element>
        </xsl:element>
                
        <!-- Sign SDC -->
        <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
          <xsl:element name="command_id">sign_sdc_1</xsl:element>
          <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
            <xsl:element name="supported_object_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">S</xsl:element>
            <xsl:element name="apply_swap_date">
              <xsl:value-of select="$dayAfterDesiredDate"/>
            </xsl:element>
            <xsl:element name="board_sign_name">ARCOR</xsl:element>
            <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>
            </xsl:element>          
            <xsl:element name="required_process_ind">S</xsl:element>          
          </xsl:element>
        </xsl:element>

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
          
          <!-- Create Comment -->
          <xsl:element name="CcmFifCreateCommentCmd">
            <xsl:element name="command_id">create_comment_1</xsl:element>
            <xsl:element name="CcmFifCreateCommentInCont">
              <xsl:element name="comment_id_ref">
                <xsl:element name="command_id">find_service_2</xsl:element>
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
      
      <!-- Reconfigure the main access service for ISDN scenario-->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
              <xsl:value-of select="$tomorrow"/>
            </xsl:if>
            <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:text>BBW </xsl:text>
                <xsl:value-of select="dateutils:getCurrentDate(false)"/>
              </xsl:element>
            </xsl:element>
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Y</xsl:element>
            </xsl:element>
            <!-- DSL Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0093</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='NEW_DSL_BANDWIDTH']"/>
              </xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Sonderzeitfenster -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0139</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">NZF</xsl:element>
            </xsl:element>
            <!-- Fixer Bestelltermin -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0140</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">Nein</xsl:element>
            </xsl:element>
            <!-- DTAG-Freitext -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0141</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Anzahl neuer Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0940</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">14</xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Bandbreitenwechsel</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">V0010</xsl:element>               
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service (V0011) -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
              <xsl:value-of select="$tomorrow"/>
            </xsl:if>
            <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:text>BBW </xsl:text>
                <xsl:value-of select="dateutils:getCurrentDate(false)"/>
              </xsl:element>
            </xsl:element>
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Y</xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Sonderzeitfenster -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0139</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NZF</xsl:element>
            </xsl:element>
            <!-- Fixer Bestelltermin -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0140</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nein</xsl:element>
            </xsl:element>
            <!-- DTAG-Freitext -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0141</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Anzahl neuer Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0940</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">14</xsl:element>
            </xsl:element>            
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Bandbreitenwechsel</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">V0011</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service for ISDN scenario-->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
              <xsl:value-of select="$tomorrow"/>
            </xsl:if>
            <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:text>BBW </xsl:text>
                <xsl:value-of select="dateutils:getCurrentDate(false)"/>
              </xsl:element>
            </xsl:element>
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Y</xsl:element>
            </xsl:element>
            <!-- DSL Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0093</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='NEW_DSL_BANDWIDTH']"/>
              </xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Sonderzeitfenster -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0139</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NZF</xsl:element>
            </xsl:element>
            <!-- Fixer Bestelltermin -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0140</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nein</xsl:element>
            </xsl:element>
            <!-- DTAG-Freitext -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0141</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element> 
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0940</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">14</xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Bandbreitenwechsel</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">V0003</xsl:element>               
        </xsl:element>
      </xsl:element>
            
     
       <!-- execute only if ISDN-->
      <!-- Find the exclusive child service subscription for main service -->
      <!-- added process_ind_ref and required_process_ind for executing only if ISDN-->
      <xsl:if test="((request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 8000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 10000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 12000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 16000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 20000'))">
        
        <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
          <xsl:element name="command_id">find_excl_child_1</xsl:element>
          <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0113</xsl:element>
              </xsl:element>
            </xsl:element>       
          </xsl:element>
        </xsl:element>
        
        <!-- Reconfigure the DSL Service for ISDN scenario-->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_2</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_excl_child_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
                <xsl:value-of select="$tomorrow"/>
              </xsl:if>
              <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
                <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
              </xsl:if>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="ignore_empty_service_id">Y</xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- DSLBandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0826</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='NEW_DSL_BANDWIDTH']"/>
                </xsl:element>
              </xsl:element>
              <!-- DSL Upstream Bandwidth -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0092</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='NEW_UPSTREAM_BANDWIDTH']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>      
          </xsl:element>
        </xsl:element>
        
        <!-- terminate Old DSL ATM 3.35 if exist for ISDN scenario-->
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_dsl_ss</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_date">
              <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
                <xsl:value-of select="$tomorrow"/>
              </xsl:if>
              <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
                <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
              </xsl:if>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="service_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0088</xsl:element>
              </xsl:element>
            </xsl:element>           
          </xsl:element>
        </xsl:element>
  
        <!-- DSL Service for ISDN scenario-->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_0</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0113</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
                <xsl:value-of select="$tomorrow"/>
              </xsl:if>
              <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
                <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
              </xsl:if>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">term_dsl_ss</xsl:element>
              <xsl:element name="field_name">termination_performed</xsl:element>
            </xsl:element>
            <xsl:element name="additional_process_ind_ref">
              <xsl:element name="command_id">validate_service_code</xsl:element>
              <xsl:element name="field_name">service_code_valid</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_additional_process_ind">Y</xsl:element>                  
            <xsl:element name="service_characteristic_list">
              <!-- DSLBandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0826</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='NEW_DSL_BANDWIDTH']"/>
                </xsl:element>
              </xsl:element>
              <!-- DSL Upstream Bandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0092</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='NEW_UPSTREAM_BANDWIDTH']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 
     
      <xsl:if test="((request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 500') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 1000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 1500') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 2000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 3000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 4000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 5000') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 6000'))">
        <!-- Find the exclusive child service subscription for main service in ISDN scenario -->
        <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
          <xsl:element name="command_id">find_excl_child_1</xsl:element>
          <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0113</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0088</xsl:element>
              </xsl:element>
            </xsl:element>       
          </xsl:element>
        </xsl:element>
        
        <!-- Reconfigure the DSL Service  in ISDN scenario-->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_2</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_excl_child_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:if test="request-param[@name='DESIRED_DATE'] = $today">
                <xsl:value-of select="$tomorrow"/>
              </xsl:if>
              <xsl:if test="request-param[@name='DESIRED_DATE'] != $today">
                <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
              </xsl:if>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="ignore_empty_service_id">Y</xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- DSLBandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0826</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='NEW_DSL_BANDWIDTH']"/>
                </xsl:element>
              </xsl:element>
              <!-- DSL Upstream Bandwidth -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0092</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='NEW_UPSTREAM_BANDWIDTH']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Only terminate if the DSL bandwidth is changing  for ISDN-->
      <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
        <xsl:element name="command_id">term_ss_1</xsl:element>
        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="no_child_error_ind">N</xsl:element>
          <xsl:element name="desired_date">
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != $today) 
            	      and (request-param[@name='DESIRED_DATE'] != $tomorrow)">
              <xsl:value-of select="$oldBandwidthTerminationDate"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] = $today)
            	       or (request-param[@name='DESIRED_DATE'] = $tomorrow)">
              <xsl:value-of select="$tomorrow"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0115</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0116</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0117</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0118</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0133</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0134</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0174</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0175</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0176</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0177</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0178</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0179</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0180</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018A</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018B</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018C</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018D</xsl:element>
            </xsl:element>
          </xsl:element> 
        </xsl:element>
      </xsl:element>
      
           
      <!-- Only add if the DSL bandwidth is changing  for ISDN-->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'Standard'">
            <xsl:element name="service_code">V0133</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'Premium'">
            <xsl:element name="service_code">V0116</xsl:element>
          </xsl:if>
          <xsl:if test="((request-param[@name='NEW_DSL_BANDWIDTH'] = 'Gold') or
        (request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 1500'))">
            <xsl:element name="service_code">V0117</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 1000'">
            <xsl:element name="service_code">V0118</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 2000'">
            <xsl:element name="service_code">V0174</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 3000'">
            <xsl:element name="service_code">V0175</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 4000'">
            <xsl:element name="service_code">V0176</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 5000'">
            <xsl:element name="service_code">V0177</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 6000'">
            <xsl:element name="service_code">V0178</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 500'">
            <xsl:element name="service_code">V0179</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 8000'">
            <xsl:element name="service_code">V0180</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 10000'">
            <xsl:element name="service_code">V018A</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 12000'">
            <xsl:element name="service_code">V018B</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 16000'">
            <xsl:element name="service_code">V018C</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 20000'">
            <xsl:element name="service_code">V018D</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 25000'">
            <xsl:element name="service_code">V018G</xsl:element>
          </xsl:if>            
          <xsl:if test="request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 50000'">
            <xsl:element name="service_code">V018H</xsl:element>
          </xsl:if>            
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:if test="(request-param[@name='DESIRED_DATE'] = $today)
            	       or (request-param[@name='DESIRED_DATE'] = $tomorrow)">
              <xsl:value-of select="$dayAfterTomorrow"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != $today) 
            	      and (request-param[@name='DESIRED_DATE'] != $tomorrow)">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>   
          <xsl:element name="service_characteristic_list">
          </xsl:element>
          </xsl:element>
      </xsl:element>
      
        

      <!-- Add DSL 1500 Upstream Service, if requested -->
      <xsl:if test="(request-param[@name='NEW_DSL_BANDWIDTH'] = 'Gold')
                    and (request-param[@name='NEW_UPSTREAM_BANDWIDTH'] = '384')">
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_2</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">V0197</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:if test="(request-param[@name='DESIRED_DATE'] = $today)
                           or (request-param[@name='DESIRED_DATE'] = $tomorrow)">
                <xsl:value-of select="$dayAfterTomorrow"/>
                </xsl:if>
                <xsl:if test="(request-param[@name='DESIRED_DATE'] != $today) 
                          and (request-param[@name='DESIRED_DATE'] != $tomorrow)">
                  <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
                </xsl:if>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list">
              </xsl:element>
              
            </xsl:element>
          </xsl:element>
      </xsl:if>
     
      <!-- Add DSL 2000 Upstream Service, if requested -->
      <xsl:if test="(request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 2000')
                    and (request-param[@name='NEW_UPSTREAM_BANDWIDTH'] = '384')">
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_2</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">V0198</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:if test="(request-param[@name='DESIRED_DATE'] = $today)
                           or (request-param[@name='DESIRED_DATE'] = $tomorrow)">
                <xsl:value-of select="$dayAfterTomorrow"/>
                </xsl:if>
                <xsl:if test="(request-param[@name='DESIRED_DATE'] != $today) 
                          and (request-param[@name='DESIRED_DATE'] != $tomorrow)">
                  <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
                </xsl:if>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>            
              <xsl:element name="service_characteristic_list">
              </xsl:element>
            </xsl:element>
          </xsl:element>
      </xsl:if>
        
      <!-- Add DSL 3000 Upstream Service, if requested -->
      <xsl:if test="(request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 3000')
                    and (request-param[@name='NEW_UPSTREAM_BANDWIDTH'] = '512')">
        <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_2</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">V0199</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:if test="(request-param[@name='DESIRED_DATE'] = $today)
                           or (request-param[@name='DESIRED_DATE'] = $tomorrow)">
                <xsl:value-of select="$dayAfterTomorrow"/>
                </xsl:if>
                <xsl:if test="(request-param[@name='DESIRED_DATE'] != $today) 
                          and (request-param[@name='DESIRED_DATE'] != $tomorrow)">
                  <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
                </xsl:if>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list">
              </xsl:element>
             
            </xsl:element>
          </xsl:element>
      </xsl:if>

      <!-- Add DSL 4000 Upstream Service, if requested -->
      <xsl:if test="(request-param[@name='NEW_DSL_BANDWIDTH'] = 'DSL 4000')
                    and (request-param[@name='NEW_UPSTREAM_BANDWIDTH'] = '512')">
        <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_2</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">V0199</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:if test="(request-param[@name='DESIRED_DATE'] = $today)
                           or (request-param[@name='DESIRED_DATE'] = $tomorrow)">
                <xsl:value-of select="$dayAfterTomorrow"/>
                </xsl:if>
                <xsl:if test="(request-param[@name='DESIRED_DATE'] != $today) 
                          and (request-param[@name='DESIRED_DATE'] != $tomorrow)">
                  <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
                </xsl:if>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list">
              </xsl:element>
              
            </xsl:element>
          </xsl:element>
      </xsl:if>

          
      <!-- Create Customer Order for Termination for ISDN -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">Bandbreitenwechsel</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <!-- DSL service termination -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_ss_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
          
        </xsl:element>
      </xsl:element>
      

      <!-- Create Customer Order for new services   for ISDN -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">Bandbreitenwechsel</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <!-- Reconfiguration of main access service -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- Reconfiguration of DSL service -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- Adding the DSL service -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_0</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- DSL Bandwidth change -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- Upstream bandwidth change -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_dsl_ss</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>         
          </xsl:element>
        </xsl:element>
      </xsl:element>
     

      <!-- Release Customer Order for termination in case of ISDN -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="command_id">release_co_1</xsl:element>
        <xsl:element name="CcmFifReleaseCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>
        </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
     

      <!-- Release Customer Order for new services in case of ISDN -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="command_id">release_co_2</xsl:element>
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>



      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="short_description">Bandbreitenwechsel</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='USER_NAME']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='ROLLEN_BEZEICHNUNG']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">CONTACT</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CATEGORY</xsl:element>
              <xsl:element name="parameter_value">Bandwidth</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='USER_NAME']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">WORK_DATE</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="$today"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>Bandbreitenwechsel zu </xsl:text>
                <xsl:value-of select="request-param[@name='NEW_DSL_BANDWIDTH']"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="request-param[@name='NEW_UPSTREAM_BANDWIDTH']"/>
                <xsl:text>.</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>     
        </xsl:element>
      </xsl:element>

    </xsl:element>

</xsl:element>
