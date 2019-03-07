<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for billing activation of the product subscription
  
  @author lejam 
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
      
        
        <!-- Find product subscription for service subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Actviate Billing Product Subscription -->
        <xsl:element name="CcmFifActivateProductSubsBillingCmd">
          <xsl:element name="command_id">transition_ps</xsl:element>
          <xsl:element name="CcmFifActivateProductSubsBillingInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element> 
            <xsl:element name="billing_activation_date">
              <xsl:if test="request-param[@name='billingActivationDate']=''">
                <xsl:value-of select="dateutils:getCurrentDate()"/>
              </xsl:if>        
              <xsl:if test="request-param[@name='billingActivationDate']!=''">
                <xsl:value-of select="request-param[@name='billingActivationDate']"/>
              </xsl:if>        
            </xsl:element>
            <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="field_name">billing_activated</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">N</xsl:element>           
          </xsl:element>
        </xsl:element>

        <!-- Create contact -->
        <xsl:element name="CcmFifCreateContactCmd">
         <xsl:element name="command_id">create_contact_1</xsl:element>
         <xsl:element name="CcmFifCreateContactInCont">
           <xsl:element name="customer_number_ref">
             <xsl:element name="command_id">find_service</xsl:element>
             <xsl:element name="field_name">customer_number</xsl:element>
           </xsl:element>
           <xsl:element name="contact_type_rd">PROD_SUBS</xsl:element>
           <xsl:element name="short_description">Activate Billing</xsl:element>
           <xsl:element name="description_text_list">
             <xsl:element name="CcmFifPassingValueCont">
               <xsl:element name="contact_text">
                 <xsl:text>Executed ActivateBilling transaction for the product subscription </xsl:text>
               </xsl:element>
             </xsl:element>
             <xsl:element name="CcmFifCommandRefCont">
               <xsl:element name="command_id">find_service</xsl:element>
               <xsl:element name="field_name">product_subscription_id</xsl:element>          
             </xsl:element>
             <xsl:element name="CcmFifPassingValueCont">
               <xsl:element name="contact_text">
                 <xsl:text> with the activation date </xsl:text>
                   <xsl:if test="request-param[@name='billingActivationDate']=''">
                     <xsl:value-of select="dateutils:getCurrentDate()"/>
                   </xsl:if>        
                   <xsl:if test="request-param[@name='billingActivationDate']!=''">
                     <xsl:value-of select="request-param[@name='billingActivationDate']"/>
                   </xsl:if>        
                 <xsl:text>.</xsl:text>
               </xsl:element>
             </xsl:element>
             <xsl:element name="CcmFifPassingValueCont">
               <xsl:element name="contact_text">
                 <xsl:text>&#xA;TransactionID: </xsl:text>
                 <xsl:value-of select="request-param[@name='transactionID']"/>
                 <xsl:text>&#xA;FIF-Client: </xsl:text>
                 <xsl:value-of select="request-param[@name='clientName']"/>
               </xsl:element>
             </xsl:element>
           </xsl:element>
           <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">billing_activated</xsl:element>
           </xsl:element>
           <xsl:element name="required_process_ind">N</xsl:element>           
         </xsl:element>
       </xsl:element>
      
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
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">ccbId</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionStatus</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">SUCCESS</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
