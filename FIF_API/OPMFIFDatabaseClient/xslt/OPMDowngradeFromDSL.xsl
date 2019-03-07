<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated downgrade from DSL FIF request

  @author schwarje
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
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">OPM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="desiredDateOPM"
        select="dateutils:createOPMDate(request-param[@name='DESIRED_DATE'])"/>
      <xsl:variable name="today"
          select="dateutils:getCurrentDate()"/>
      <xsl:variable name="tomorrow"
          select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
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

      <!-- Validate the service subscription state -->
      <xsl:element name="CcmFifValidateServiceSubsStateCmd">
        <xsl:element name="command_id">validate_ss_state_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceSubsStateInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_state">SUBSCRIBED</xsl:element>
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

      <!-- Validate that there is maximum one service -->
      <xsl:element name="CcmFifValidateOneOrNoServSubscCmd">
        <xsl:element name="command_id">validate_max_one_ss_1</xsl:element>
        <xsl:element name="CcmFifValidateOneOrNoServSubscInCont">
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

      <!-- Validate no uncomplete STPs -->
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
        </xsl:if>
        
      </xsl:if>
      
      <!-- Reconfigure the main access service (V0010) -->
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
          <xsl:element name="reason_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">N</xsl:element>
            </xsl:element>
            <!-- Alter Anschluss -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0094</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">digital</xsl:element>
            </xsl:element>
            <!-- Anzahl neuer Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Remigration</xsl:element>
            </xsl:element>
            <!-- DSL Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0093</xsl:element>
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
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nur DSL-Kündigung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NoOP</xsl:element>
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
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0940</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">12</xsl:element>
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
          <xsl:element name="reason_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">N</xsl:element>
            </xsl:element>
            <!-- Alter Anschluss -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0094</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">digital</xsl:element>
            </xsl:element>
            <!-- Anzahl neuer Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Remigration</xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nur DSL-Kündigung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NoOP</xsl:element>
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
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0940</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">12</xsl:element>
            </xsl:element>            
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">V0011</xsl:element>
        </xsl:element>
      </xsl:element>
   
      <!-- Reconfigure the main access service (V0003) -->
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
          <xsl:element name="reason_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">N</xsl:element>
            </xsl:element>
            <!-- Alter Anschluss -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0094</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">digital</xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Remigration</xsl:element>
            </xsl:element>
            <!-- DSL Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0093</xsl:element>
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
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nur DSL-Kündigung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NoOP</xsl:element>
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
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0940</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">12</xsl:element>
            </xsl:element>            
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">V0003</xsl:element>
        </xsl:element>
      </xsl:element>
         
      <!-- Terminate DSL Services -->
      <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
        <xsl:element name="command_id">term_ss_1</xsl:element>
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
          <xsl:element name="reason_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0074</xsl:element>
            </xsl:element>          	
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0112</xsl:element>
            </xsl:element>                        
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
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

      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">DSL-Remigration</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_ss_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
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

      <!-- look for a voice-online bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
      
       <!-- look for an online bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_2</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>          
          <xsl:element name="bundle_item_type_rd">ONLINE_SERVICE</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>


      <!-- look for a DSL-online bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_3</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>          
          <xsl:element name="bundle_item_type_rd">DSLONL_SERVICE</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

            
      <!-- Find online SS ID by bundled SS id, if a bundle was found -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_2</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_bundle_2</xsl:element>
            <xsl:element name="field_name">supported_object_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>                  
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_2</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>           
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find DSL-online SS ID by bundled SS id, if a bundle was found -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_3</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_bundle_3</xsl:element>
            <xsl:element name="field_name">supported_object_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>                  
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_3</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>           
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
        
      <!-- Terminate online Order Form -->
      <xsl:element name="CcmFifTerminateOrderFormCmd">
        <xsl:element name="command_id">terminate_of_1</xsl:element>
        <xsl:element name="CcmFifTerminateOrderFormInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_2</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="override_restriction">Y</xsl:element>
          <xsl:element name="termination_reason_rd">KKG</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_2</xsl:element>
            <xsl:element name="field_name">contract_type_rd</xsl:element>           
          </xsl:element>
          <xsl:element name="required_process_ind">O</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Terminate (DSL)online Order Form -->
      <xsl:element name="CcmFifTerminateOrderFormCmd">
        <xsl:element name="command_id">terminate_of_2</xsl:element>
        <xsl:element name="CcmFifTerminateOrderFormInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_3</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="override_restriction">Y</xsl:element>
          <xsl:element name="termination_reason_rd">KKG</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_3</xsl:element>
            <xsl:element name="field_name">contract_type_rd</xsl:element>           
          </xsl:element>
          <xsl:element name="required_process_ind">O</xsl:element>
        </xsl:element>
      </xsl:element>
                        
		<!-- Terminate online SDCPC -->
		<xsl:element name="CcmFifTerminateSDCProductCommitmentCmd">
			<xsl:element name="command_id">terminate_sdc_pc_1</xsl:element>
			<xsl:element name="CcmFifTerminateSDCProductCommitmentInCont">
				<xsl:element name="product_commitment_number_ref">
					<xsl:element name="command_id">find_service_2</xsl:element>
					<xsl:element name="field_name">product_commitment_number</xsl:element>
				</xsl:element>
				<xsl:element name="termination_date">
					<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
				</xsl:element>
				<xsl:element name="notice_per_start_date">
               <xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="override_restriction">Y</xsl:element>
				<xsl:element name="termination_reason_rd">KKG</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_service_2</xsl:element>
					<xsl:element name="field_name">contract_type_rd</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">S</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- Terminate (DSL) online SDCPC -->
		<xsl:element name="CcmFifTerminateSDCProductCommitmentCmd">
			<xsl:element name="command_id">terminate_sdc_pc_1</xsl:element>
			<xsl:element name="CcmFifTerminateSDCProductCommitmentInCont">
				<xsl:element name="product_commitment_number_ref">
					<xsl:element name="command_id">find_service_3</xsl:element>
					<xsl:element name="field_name">product_commitment_number</xsl:element>
				</xsl:element>
				<xsl:element name="termination_date">
					<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
				</xsl:element>
				<xsl:element name="notice_per_start_date">
               <xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="override_restriction">Y</xsl:element>
				<xsl:element name="termination_reason_rd">KKG</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_service_3</xsl:element>
					<xsl:element name="field_name">contract_type_rd</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">S</xsl:element>
			</xsl:element>
		</xsl:element>

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="short_description">DSL-Remigration</xsl:element>
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
              <xsl:element name="parameter_value">DSL-Downgrade</xsl:element>
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
                <xsl:text>DSL-Downgrade</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>     
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
