<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a service delivery contract
  
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
    
    <!-- Calculate desiredDate -->
    <xsl:variable name="desiredDate" select="dateutils:getCurrentDate()"/>
   
    <xsl:element name="Command_List">
      
     
                 
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
          <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
            <xsl:element name="command_id">cancel_stp_1</xsl:element>
            <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="reason_rd">TERMINATION</xsl:element>
            </xsl:element>
          </xsl:element>
          
         <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact_1</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
            <xsl:element name="short_description">Kündigung</xsl:element>
            <xsl:element name="description_text_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>Die Produktnutzung </xsl:text>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>          
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text> (Vertrag </xsl:text>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>          
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>, Serviceschein </xsl:text>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>          
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>) wurde gemäß TKG §46 </xsl:text> 
                  <xsl:if test="request-param[@name='action'] = 'suspend'">
             		  <xsl:text>gesperrt. </xsl:text>  
              	  </xsl:if>
              	  <xsl:if test="request-param[@name='action'] = 'reactivate'">
             		  <xsl:text>reaktiviert. </xsl:text>  
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
