<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
   XSLT file for validating if access services still exist in CCM 
   
   @author sibanipa
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
         

      <!-- checks, if access services still exist in CCM -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
         <xsl:element name="command_id">find_main_service</xsl:element>
         <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
               </xsl:element>
             <xsl:element name="no_service_error">N</xsl:element> 
         </xsl:element>
      </xsl:element>   

      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">error_bill_not_active_text</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>CCM4228 Billing is not active for product subscription </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>          
            </xsl:element>
          </xsl:element>
        </xsl:element>      
      </xsl:element>      

      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">error_bill_not_active</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
           <xsl:element name="error_text_ref">
             <xsl:element name="command_id">error_bill_not_active_text</xsl:element>
             <xsl:element name="field_name">output_string</xsl:element>          
           </xsl:element>
           <!--<xsl:element name="ccm_error_code">144228</xsl:element>-->              
           <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">
                 <xsl:text>find_main_service</xsl:text>
              </xsl:element>
              <xsl:element name="field_name">billing_activated</xsl:element>
           </xsl:element>
           <xsl:element name="required_process_ind">N</xsl:element>                  
        </xsl:element>
      </xsl:element>      
         
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
