<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for processing UpdateEmailStatusService

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
      
      	<xsl:variable name="ccmStatus">
      		<xsl:choose>
      			<xsl:when test="request-param[@name='Status'] = 'validate'">SUCCESS</xsl:when>
      			<xsl:when test="request-param[@name='Status'] = 'softbounce'">IN_PROGRESS</xsl:when>
      			<xsl:when test="request-param[@name='Status'] = 'hardbounce'">FAILED</xsl:when>
      			<xsl:when test="request-param[@name='Status'] = 'timeout'">FAILED</xsl:when>
      			<xsl:when test="request-param[@name='Status'] = 'unknown'">IN_PROGRESS</xsl:when>
      			<xsl:otherwise>unexpectedStatus</xsl:otherwise>
      		</xsl:choose>
      	</xsl:variable>
      
      	<xsl:variable name="ccmErrorCode">
      		<xsl:choose>
      			<xsl:when test="request-param[@name='BounceReasonCode'] != ''">
					<xsl:value-of select="request-param[@name='BounceReasonCode']"/>
				</xsl:when>
      			<xsl:when test="request-param[@name='BounceReasonCode'] = '' and 
      							request-param[@name='Status'] != 'validate'">
					<xsl:value-of select="request-param[@name='Status']"/>
				</xsl:when>
      		</xsl:choose>
      	</xsl:variable>
      
      	<xsl:variable name="ccmErrorMessage">
      		<xsl:choose>
      			<xsl:when test="request-param[@name='BounceReason'] != ''">
					<xsl:value-of select="request-param[@name='BounceReason']"/>
				</xsl:when>
      			<xsl:when test="request-param[@name='BounceReason'] = '' and 
      							request-param[@name='Status'] != 'validate'">
      				<xsl:text>Status der E-Mail-Validierung: </xsl:text>
      				<xsl:value-of select="request-param[@name='Status']"/>
      			</xsl:when>
      		</xsl:choose>
      	</xsl:variable>
      
        <!-- Find Service Subscription by access number,or service_subscription id  if no bundle was found -->
        <xsl:element name="CcmFifUpdateEmailValidationCmd">
          <xsl:element name="command_id">updateValidation</xsl:element>
          <xsl:element name="CcmFifUpdateEmailValidationInCont">
            <xsl:element name="email_validation_id">
              <xsl:value-of select="request-param[@name='ValidationId']"/>
            </xsl:element>
            <xsl:element name="state_rd">
            	<xsl:value-of select="$ccmStatus"/>
            </xsl:element>
           	<xsl:element name="error_code">
           		<xsl:value-of select="$ccmErrorCode"/>        	
           	</xsl:element>
           	<xsl:element name="error_message">
           		<xsl:value-of select="$ccmErrorMessage"/>
           	</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:variable name="longDescription">
        	<xsl:text>E-Mail-Validierung </xsl:text>
        	<xsl:value-of select="request-param[@name='ValidationId']"/>
        	<xsl:text> für E-Mail-Adresse </xsl:text>
        	<xsl:value-of select="request-param[@name='Email']"/>
        	<xsl:choose>
          		<xsl:when test="$ccmStatus = 'SUCCESS'"> erfolgreich.</xsl:when>
          		<xsl:when test="$ccmStatus = 'IN_PROGRESS'"> läuft.</xsl:when>
          		<xsl:when test="$ccmStatus = 'FAILED'"> gescheitert.</xsl:when>
        	</xsl:choose>
        	<xsl:if test="$ccmErrorCode != ''">
	            <xsl:text>&#xA;Fehlercode: </xsl:text>
	            <xsl:value-of select="$ccmErrorCode"/>
	            <xsl:text>, Fehlermeldung: </xsl:text>
	            <xsl:value-of select="$ccmErrorMessage"/>
	        </xsl:if>
        	<xsl:text>&#xA;TransactionId: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
        </xsl:variable>
        
        <xsl:variable name="shortDescription">
        	<xsl:text>E-Mail-Validierung</xsl:text>        	
        	<xsl:choose>
          		<xsl:when test="$ccmStatus = 'SUCCESS'"> erfolgreich</xsl:when>
          		<xsl:when test="$ccmStatus = 'IN_PROGRESS'"> läuft</xsl:when>
          		<xsl:when test="$ccmStatus = 'FAILED'"> gescheitert</xsl:when>
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
        
        <xsl:if test="$ccmStatus = 'FAILED'">
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
						<xsl:value-of select="request-param[@name='BounceReason']"/>
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
		
		<xsl:if test="request-param[@name='Status'] = 'hardbounce'">

			<xsl:variable name="today">  
				<xsl:value-of select="dateutils:getCurrentDate()"/>
			</xsl:variable>
			<xsl:variable name="tomorrow">  
				<xsl:value-of select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
			</xsl:variable>
	
			<!-- get account for customer -->
			<xsl:element name="CcmFifFindAccountCmd">
				<xsl:element name="command_id">find_account</xsl:element>
				<xsl:element name="CcmFifFindAccountInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">updateValidation</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="no_account_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			      
			<xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
				<xsl:element name="command_id">get_document_recipient</xsl:element>
				<xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">updateValidation</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_account</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>					
					<xsl:element name="effective_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_account</xsl:element>
						<xsl:element name="field_name">account_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">updateValidation</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>          
	
	        <!-- checks, if customer's entity and document recipient's are the same -->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">one_entity</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">Entity</xsl:element>
					<xsl:element name="value_type">EntityID</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">get_document_recipient</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_failure_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>			
	
	        <!-- checks, if customer's entity and document recipient's are the same -->
			<xsl:element name="CcmFifGetAccessInfoCmd">
				<xsl:element name="command_id">customer_email</xsl:element>
				<xsl:element name="CcmFifGetAccessInfoInCont">
					<xsl:element name="access_information_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">primary_access_info_id</xsl:element>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>			

	        <!-- checks, if customer's entity and document recipient's are the same -->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">customer_uses_email</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value">
						<xsl:value-of select="request-param[@name='Email']"/>
					</xsl:element>
					<xsl:element name="object_type">AccessInformation</xsl:element>
					<xsl:element name="value_type">EmailAddress</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">customer_email</xsl:element>
						<xsl:element name="field_name">email_address</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_failure_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>			
		

			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">map_cloneEntity</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">XXX</xsl:element>
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">one_entity</xsl:element>
							<xsl:element name="field_name">success_ind</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">;</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">customer_uses_email</xsl:element>
							<xsl:element name="field_name">success_ind</xsl:element>							
						</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">XXX</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">Y;Y</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">N</xsl:element>
				</xsl:element>
			</xsl:element>

	        <!-- checks, if customer's entity and document recipient's are the same -->
			<xsl:element name="CcmFifCloneEntityCmd">
				<xsl:element name="command_id">clone_entity</xsl:element>
				<xsl:element name="CcmFifCloneEntityInCont">
					<xsl:element name="entity_id_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="associate_customer">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">map_cloneEntity</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- assign cloned entity to document recipient -->
			<xsl:element name="CcmFifModifyDocumentRecipientCmd">
				<xsl:element name="command_id">modify_doc_recipient</xsl:element>
				<xsl:element name="CcmFifModifyDocumentRecipientInCont">
					<xsl:element name="document_recipient_ref">
						<xsl:element name="command_id">get_document_recipient</xsl:element>
						<xsl:element name="field_name">document_recipient_id</xsl:element>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">clone_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="access_information_ref">
						<xsl:element name="command_id">clone_entity</xsl:element>
						<xsl:element name="field_name">access_information_id</xsl:element>
					</xsl:element>          
					<xsl:element name="address_ref">
						<xsl:element name="command_id">clone_entity</xsl:element>
						<xsl:element name="field_name">address_id</xsl:element>
					</xsl:element>          
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">map_cloneEntity</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifUpdatePermissionPreferenceCmd">
				<xsl:element name="command_id">update_permissions</xsl:element>
				<xsl:element name="CcmFifUpdatePermissionPreferenceInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">updateValidation</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="source_system_id">CCB.CCM</xsl:element>
					<xsl:element name="permission_preference_list">
						<xsl:element name="CcmFifPermissionPreferenceCont">
							<xsl:element name="permission_id">ADV</xsl:element>
							<xsl:element name="service_id">EMAL</xsl:element>
							<xsl:element name="permission_value">N</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">customer_uses_email</xsl:element>
						<xsl:element name="field_name">success_ind</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Update Access Information -->
			<xsl:element name="CcmFifUpdateAccessInformCmd">
				<xsl:element name="command_id">remove_email_address</xsl:element>
				<xsl:element name="CcmFifUpdateAccessInformInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>          
					<xsl:element name="access_information_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">primary_access_info_id</xsl:element>
					</xsl:element>          
					<xsl:element name="effective_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="email_address">**NULL**</xsl:element>
					<xsl:element name="electronic_contact_indicator">N</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">customer_uses_email</xsl:element>
							<xsl:element name="field_name">success_ind</xsl:element>							
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:if>		    
        
    </xsl:element>   
  </xsl:template>
</xsl:stylesheet>
