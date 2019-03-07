<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for reponse handling of the ValidateEmailAddressService

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
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
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="package_name">
      <xsl:value-of select="request-param[@name='packageName']"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
      
        <!-- Find Service Subscription by access number,or service_subscription id  if no bundle was found -->
        <xsl:element name="CcmFifUpdateEmailValidationCmd">
          <xsl:element name="command_id">updateValidation</xsl:element>
          <xsl:element name="CcmFifUpdateEmailValidationInCont">
            <xsl:element name="email_validation_id">
              <xsl:value-of select="request-param[@name='ValidationId']"/>
            </xsl:element>
            <xsl:element name="state_rd">
            	<xsl:choose>
            		<xsl:when test="request-param[@name='CancelInd'] = '1'">CANCELED</xsl:when>
            		<xsl:when test="request-param[@name='CancelInd'] != '1' and 
            			request-param[@name='originalRequestResult'] = 'true'">IN_PROGRESS</xsl:when>
            		<xsl:when test="request-param[@name='CancelInd'] != '1' and 
            			request-param[@name='originalRequestResult'] = 'false'">FAILED</xsl:when>
            	</xsl:choose>
            </xsl:element>
            <xsl:if test="request-param[@name='originalRequestResult'] = 'false'">
            	<xsl:element name="error_code">
            		<xsl:value-of select="request-param[@name='originalRequestErrorCode']"/>                	
            	</xsl:element>
            	<xsl:element name="error_message">
            		<xsl:value-of select="request-param[@name='originalRequestErrorText']"/>
            	</xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
        
        <xsl:variable name="longDescription">
        	<xsl:text>E-Mail-Validierung </xsl:text>
        	<xsl:value-of select="request-param[@name='ValidationId']"/>
        	<xsl:text> für E-Mail-Adresse </xsl:text>
        	<xsl:value-of select="request-param[@name='Email']"/>
        	<xsl:choose>
          		<xsl:when test="request-param[@name='CancelInd'] = '1'"> storniert.</xsl:when>
          		<xsl:when test="request-param[@name='CancelInd'] != '1' and 
          			request-param[@name='originalRequestResult'] = 'true'"> bestätigt.</xsl:when>
          		<xsl:when test="request-param[@name='CancelInd'] != '1' and 
          			request-param[@name='originalRequestResult'] = 'false'"> abgebrochen.</xsl:when>
        	</xsl:choose>
        	<xsl:if test="request-param[@name='originalRequestResult'] = 'false'">
	            <xsl:text>&#xA;Fehlercode: </xsl:text>
	            <xsl:value-of select="request-param[@name='originalRequestErrorCode']"/>
	            <xsl:text>, Fehlermeldung: </xsl:text>
	            <xsl:value-of select="request-param[@name='originalRequestErrorText']"/>
	        </xsl:if>
        	<xsl:text>&#xA;TransactionId: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
        </xsl:variable>
        
        <xsl:variable name="shortDescription">
        	<xsl:text>E-Mail-Validierung</xsl:text>        	
        	<xsl:choose>
          		<xsl:when test="request-param[@name='CancelInd'] = '1'"> storniert</xsl:when>
          		<xsl:when test="request-param[@name='CancelInd'] != '1' and 
          			request-param[@name='originalRequestResult'] = 'true'"> bestätigt</xsl:when>
          		<xsl:when test="request-param[@name='CancelInd'] != '1' and 
          			request-param[@name='originalRequestResult'] = 'false'"> abgebrochen</xsl:when>
        	</xsl:choose>      
        </xsl:variable>
        
        <!-- Create Contact documenting the result -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">updateValidation</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">EMAILVALIDATION</xsl:element>
            <xsl:element name="short_description">
              <xsl:value-of select="$shortDescription"/>
            </xsl:element>
            <xsl:element name="long_description_text">
              <xsl:value-of select="$longDescription"/>
            </xsl:element>
            <xsl:element name="ignore_no_customer_error">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
		<xsl:if test="request-param[@name='CancelInd'] != '1' and request-param[@name='originalRequestResult'] = 'false'">
	        <!-- Create external notification -->
	        <xsl:element name="CcmFifCreateExternalNotificationCmd">
	          <xsl:element name="command_id">create_kba_notification</xsl:element>
	          <xsl:element name="CcmFifCreateExternalNotificationInCont">
	            <xsl:element name="effective_date">
	              <xsl:value-of select="dateutils:getCurrentDate()"/>
	            </xsl:element>
	            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
	            <xsl:element name="target_system">KBA</xsl:element>                           				
	            <xsl:element name="parameter_value_list">
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>		
	                <xsl:element name="parameter_value_ref">
	                  <xsl:element name="command_id">updateValidation</xsl:element>
	                  <xsl:element name="field_name">customer_number</xsl:element>
	                </xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">TYPE</xsl:element>
	                <xsl:element name="parameter_value">CONTACT</xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">ACTION</xsl:element>
	                <xsl:element name="parameter_value">emailValidationBouncedAction</xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">CATEGORY</xsl:element>
	                <xsl:element name="parameter_value">emailValidationBounced</xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">USER_NAME</xsl:element>
	                <xsl:element name="parameter_value">FIF</xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
	                <xsl:element name="parameter_value">CCB</xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
	                <xsl:element name="parameter_value">
	                  <xsl:value-of select="dateutils:getCurrentDate()"/>
	                </xsl:element>
	              </xsl:element>					
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">email</xsl:element>
	                <xsl:element name="parameter_value">
						<xsl:value-of select="request-param[@name='Email']"/>                	
	                </xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">bounceReason</xsl:element>
	                <xsl:element name="parameter_value">
						<xsl:value-of select="request-param[@name='originalRequestErrorText']"/>
					</xsl:element>
	              </xsl:element>
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">resultDate</xsl:element>
	                <xsl:element name="parameter_value">
						<xsl:value-of select="dateutils:createKBADate(dateutils:getCurrentDate())"/>
					</xsl:element>
	              </xsl:element>
	            </xsl:element>
	          </xsl:element>
	        </xsl:element>                  
		</xsl:if>        
        
        
        
    </xsl:element>   
  </xsl:template>
</xsl:stylesheet>
