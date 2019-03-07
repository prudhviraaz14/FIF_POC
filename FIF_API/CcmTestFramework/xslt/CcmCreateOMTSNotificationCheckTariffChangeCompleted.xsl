<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for writing to External Notification

  @author Marcin Leja
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
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
    <xsl:element name="client_name">CCM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
      
     <!-- Find order form -->
     <xsl:element name="CcmFifGetOrderFormDataCmd">
       <xsl:element name="command_id">find_order_form_1</xsl:element>
       <xsl:element name="CcmFifGetOrderFormDataInCont">
         <xsl:element name="contract_number">
           <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
         </xsl:element>
         <xsl:element name="target_state">SIGNED</xsl:element>
       </xsl:element>
     </xsl:element>

      <!-- Validate if order form has the provided customer tracking id -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_barcode_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_order_form_1</xsl:element>
            <xsl:element name="field_name">customer_tracking_id</xsl:element>
          </xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='BARCODE']"/>
              </xsl:element>          	  
            </xsl:element>
          </xsl:element>
          <xsl:element name="ignore_failure_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Check if order was initiated by COM -->
      <xsl:element name="CcmFifIsComOrderCmd">
        <xsl:element name="command_id">is_com_order</xsl:element>
        <xsl:element name="CcmFifIsComOrderInCont">
          <xsl:element name="barcode">
            <xsl:value-of select="request-param[@name='BARCODE']"/>
          </xsl:element>          	  
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">concat_output</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">validate_barcode_1</xsl:element>
              <xsl:element name="field_name">success_ind</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">;</xsl:element>							
            </xsl:element>                
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">is_com_order</xsl:element>
              <xsl:element name="field_name">is_com_order</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>            
      
     <!-- Create External Notification if validation succeded-->
     <xsl:element name="CcmFifCreateExternalNotificationCmd">
       <xsl:element name="command_id">create_external_notification_1</xsl:element>
       <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
              <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="notification_action_name">TariffChangeCompleted</xsl:element>
         <xsl:element name="target_system">OMTS</xsl:element>
         <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BARCODE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='BARCODE']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CONTRACT_NUMBER</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
              </xsl:element>
            </xsl:element>
           <xsl:element name="CcmFifParameterValueCont">
             <xsl:element name="parameter_name">PRICING_STRUCTURE_CODE</xsl:element>
             <xsl:element name="parameter_value">
               <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']"/>
             </xsl:element>
           </xsl:element>
           <xsl:element name="CcmFifParameterValueCont">
             <xsl:element name="parameter_name">PRODUCT_CODE</xsl:element>
             <xsl:element name="parameter_value">
               <xsl:value-of select="request-param[@name='PRODUCT_CODE']"/>
             </xsl:element>
           </xsl:element>
           <xsl:element name="CcmFifParameterValueCont">
             <xsl:element name="parameter_name">PRODUCT_VERSION_CODE</xsl:element>
             <xsl:element name="parameter_value">
               <xsl:value-of select="request-param[@name='PRODUCT_VERSION_CODE']"/>
             </xsl:element>
           </xsl:element>
         </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_output</xsl:element>
             <xsl:element name="field_name">output_string</xsl:element>          	
         </xsl:element>
         <xsl:element name="required_process_ind">Y;N</xsl:element>
       </xsl:element>
     </xsl:element>

      <!-- Create External Notification Ref -->
      <xsl:element name="CcmFifCreateExternalNotificationRefCmd">
        <xsl:element name="CcmFifCreateExternalNotificationRefInCont">
          <xsl:element name="transaction_id_ref">
            <xsl:element name="command_id">create_external_notification_1</xsl:element>
            <xsl:element name="field_name">transaction_id</xsl:element>
          </xsl:element>
          <xsl:element name="transaction_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="client_name">CCM</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_output</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y;N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      </xsl:element>
  </xsl:template>
</xsl:stylesheet>
