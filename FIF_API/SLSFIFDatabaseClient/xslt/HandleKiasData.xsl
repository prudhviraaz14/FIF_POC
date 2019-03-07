<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  Terminate Preselct Service

  @author Lalit
-->
<xsl:stylesheet version="1.0"
    exclude-result-prefixes="dateutils" 
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
	
	 <xsl:variable name="today"
          select="request-param[@name='desiredDate']"/>   


<xsl:variable name="text">
                <xsl:text>orderType:</xsl:text>
				<xsl:value-of select="request-param[@name='orderType']"/>
				<xsl:text>,&#xA;desiredDate:</xsl:text>
				<xsl:value-of select="request-param[@name='desiredDate']"/>
				<xsl:text>,&#xA;accessNumber:</xsl:text>
				<xsl:value-of select="request-param[@name='accessNumber']"/>
				<xsl:if test="request-param[@name='orderType'] = 'CHANGE CARRIER DATA'">
				<xsl:if test="request-param[@name='name'] != ''">
				<xsl:text>,&#xA;Name:</xsl:text>
				<xsl:value-of select="request-param[@name='name']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='firstName'] != ''">
				<xsl:text>,&#xA;firstName:</xsl:text>
				<xsl:value-of select="request-param[@name='firstName']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='streetName'] != ''">
				<xsl:text>,&#xA;streetName:</xsl:text>
				<xsl:value-of select="request-param[@name='streetName']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='streetNumber'] != ''">
				<xsl:text>,&#xA;streetNumber:</xsl:text>
				<xsl:value-of select="request-param[@name='streetNumber']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='postalCode'] != ''">
				<xsl:text>,&#xA;postalCode:</xsl:text>
				<xsl:value-of select="request-param[@name='postalCode']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='cityName'] != ''">
				<xsl:text>,&#xA;cityName:</xsl:text>
				<xsl:value-of select="request-param[@name='cityName']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='companyName'] != ''">
				<xsl:text>,&#xA;companyName:</xsl:text>
				<xsl:value-of select="request-param[@name='companyName']"/>
				</xsl:if>
				</xsl:if> 
              </xsl:variable>			  

      <!-- Find Service Subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="request-param[@name='accessNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
     <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_external_notification_1</xsl:element>
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
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">PROCESS</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CATEGORY</xsl:element>
              <xsl:element name="parameter_value">TwinStar_Usecases</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
			<xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value">SLS</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
              <xsl:element name="parameter_value">CCB</xsl:element>
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
              <xsl:value-of select="$text"/>
			 </xsl:element>
            </xsl:element>					
          </xsl:element>
        </xsl:element>
      </xsl:element> 
	  
 <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">HANDLE_KIAS_DATA</xsl:element>
          <xsl:element name="short_description">
		  <xsl:text>OrderType:</xsl:text>
            <xsl:value-of select="request-param[@name='orderType']"/>
		  </xsl:element>
          <xsl:element name="long_description_text">
		    <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
			<xsl:text>,&#xA;</xsl:text>
           <xsl:value-of select="$text"/>
        </xsl:element>
      </xsl:element>
      	  
</xsl:element>      

     
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
