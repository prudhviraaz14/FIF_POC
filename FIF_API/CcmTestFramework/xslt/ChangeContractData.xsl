<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an apply new pricing structure FIF request

  @author Aziz
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
           
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
	<xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
         
      <!-- Get Order Form Data -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="currency_rd_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">currency_rd</xsl:element>
          </xsl:element>
          <xsl:element name="language_rd_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">language_rd</xsl:element>
          </xsl:element>
          <xsl:element name="loi_indicator_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">loi_indicator</xsl:element>
          </xsl:element>
          <xsl:element name="notice_per_dur_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">notice_per_dur_value</xsl:element>
          </xsl:element>
          <xsl:element name="notice_per_dur_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">notice_per_dur_unit</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_per_dur_value</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_per_dur_unit</xsl:element>
          </xsl:element>
          <xsl:element name="term_start_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">term_start_date</xsl:element>
          </xsl:element>
          <xsl:element name="monthly_order_entry_amount_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">monthly_order_entry_amount</xsl:element>
          </xsl:element>
          <xsl:element name="termination_restriction_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">termination_restriction</xsl:element>
          </xsl:element>
          <xsl:element name="doc_template_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">doc_template_name</xsl:element>
          </xsl:element>
          <xsl:element name="product_commit_list_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">product_commit_list</xsl:element>
          </xsl:element>          
          <xsl:element name="min_period_start_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_period_start_date</xsl:element>
          </xsl:element>
          <xsl:element name="mig_17739_ind">
            <xsl:value-of select="request-param[@name='FIRST_RUN_INDICATOR']"/>
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
            <xsl:value-of select="$tomorrow"/>              
          </xsl:element>
          <xsl:element name="board_sign_name">ARCOR</xsl:element>
          <xsl:element name="board_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">board_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          <xsl:element name="primary_cust_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">primary_cust_sign_date</xsl:element>
          </xsl:element> 
          <xsl:element name="rcp_notif_blocking_ind">Y</xsl:element>                
        </xsl:element>
      </xsl:element>                   
      
      <xsl:variable name="firstRun">
        <xsl:text>IT-17739: Migration für die automatische Vertragverlängerung, Vertragsnummer: </xsl:text>
        <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>        
      </xsl:variable>
      
      <xsl:variable name="secondRun">
        <xsl:text>IT-17739: Clearing automatische Vertragverlängerung, Vertragsnummer: </xsl:text>
        <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>        
      </xsl:variable>
      
      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">CONTRACT</xsl:element>
          <xsl:element name="short_description">Migration IT-17739</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:if test="request-param[@name='FIRST_RUN_INDICATOR'] = 'Y'">
              <xsl:value-of select="$firstRun"/>
            </xsl:if>
            <xsl:if test="request-param[@name='FIRST_RUN_INDICATOR'] != 'Y'">
              <xsl:value-of select="$secondRun"/>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='FIRST_RUN_INDICATOR'] = 'Y'">
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
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
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
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
                  <xsl:value-of select="$firstRun"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='FIRST_RUN_INDICATOR'] != 'Y'">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_sls_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="$today"/>
            </xsl:element>                
            <xsl:element name="notification_action_name">IT-17739-Clearing</xsl:element>
            <xsl:element name="target_system">SLS</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
              </xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
