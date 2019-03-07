<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for validating if access numbers already exist
	
	@author schwarje
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
			
			<xsl:variable name="desiredDate">
				<xsl:value-of select="request-param[@name='desiredDate']"/>
			</xsl:variable>
			
			<xsl:for-each select="request-param-list[@name='accessNumbers']/request-param-list-item">
				<xsl:element name="CcmFifValidateAccessNumberCmd">
					<xsl:element name="command_id">
						<xsl:text>validate_access_number_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifValidateAccessNumberInCont">
						<xsl:element name="country_code">
							<xsl:value-of select="request-param[@name='countryCode']"/>
						</xsl:element>
						<xsl:element name="area_code">
							<xsl:value-of select="request-param[@name='areaCode']"/>
						</xsl:element>
						<xsl:element name="local_number">
							<xsl:value-of select="request-param[@name='localNumber']"/>
						</xsl:element>
						<xsl:element name="access_number_type">MAIN_ACCESS_NUM</xsl:element>
						<xsl:element name="duplicate_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">
						<xsl:text>find_access_number_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="access_number">
							<xsl:value-of select="request-param[@name='countryCode']"/>
							<xsl:value-of select="request-param[@name='areaCode']"/>
							<xsl:value-of select="request-param[@name='localNumber']"/>
						</xsl:element>
						<xsl:element name="access_number_type">ANY_ACCESS_NUMBER</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="technical_service_code">VOICE</xsl:element>
						<xsl:element name="no_service_error">N</xsl:element>						
						<xsl:element name="ignore_pending_termination">N</xsl:element>
						<xsl:element name="ignore_pending_com_termination">N</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>validate_access_number_</xsl:text>
								<xsl:value-of select="position()"/>
							</xsl:element>
							<xsl:element name="field_name">duplicate_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
								
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">error_text</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>CCM7002 Ein Dienst mit Rufnummer </xsl:text>
									<xsl:value-of select="request-param[@name='countryCode']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='areaCode']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='localNumber']"/>
									<xsl:text> existiert bereits, und bisher ist keine Kündigung zum </xsl:text>
									<xsl:value-of select="$desiredDate"/>
									<xsl:text> dafür vorgesehen.</xsl:text>									
									<xsl:text>&#xA;Kundennummer: </xsl:text>									
								</xsl:element>							
							</xsl:element>                
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>find_access_number_</xsl:text>
									<xsl:value-of select="position()"/>
								</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>&#xA;Dienstenutzung: </xsl:text>									
								</xsl:element>							
							</xsl:element>                
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>find_access_number_</xsl:text>
									<xsl:value-of select="position()"/>
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>&#xA;Vertragsnummer: </xsl:text>									
								</xsl:element>							
							</xsl:element>                
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>find_access_number_</xsl:text>
									<xsl:value-of select="position()"/>
								</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>      
				
				
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">raiseError</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text_ref">
							<xsl:element name="command_id">error_text</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>							
						<xsl:element name="ccm_error_code">147002</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>find_access_number_</xsl:text>
								<xsl:value-of select="position()"/>
							</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>						
					</xsl:element>
				</xsl:element>								
			</xsl:for-each>
			
			<xsl:for-each select="request-param-list[@name='accessNumberRanges']/request-param-list-item">
				<xsl:element name="CcmFifValidateAccessNumberCmd">
					<xsl:element name="command_id">
						<xsl:text>validate_access_number_range_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifValidateAccessNumberInCont">
						<xsl:element name="country_code">
							<xsl:value-of select="request-param[@name='countryCode']"/>
						</xsl:element>
						<xsl:element name="area_code">
							<xsl:value-of select="request-param[@name='areaCode']"/>
						</xsl:element>
						<xsl:element name="local_number">
							<xsl:value-of select="request-param[@name='localNumber']"/>
						</xsl:element>
						<xsl:element name="begin_number">
							<xsl:value-of select="request-param[@name='beginNumber']"/>
						</xsl:element>
						<xsl:element name="end_number">
							<xsl:value-of select="request-param[@name='endNumber']"/>
						</xsl:element>
						<xsl:element name="access_number_type">ACC_NUM_RANGE</xsl:element>
						<xsl:element name="duplicate_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
								
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">
						<xsl:text>find_access_number_range_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="access_number">
							<xsl:value-of select="request-param[@name='countryCode']"/>
							<xsl:value-of select="request-param[@name='areaCode']"/>
							<xsl:value-of select="request-param[@name='localNumber']"/>
							<xsl:value-of select="request-param[@name='beginNumber']"/>
						</xsl:element>
						<xsl:element name="access_number_type">ANY_ACCESS_NUMBER</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="technical_service_code">VOICE</xsl:element>
						<xsl:element name="no_service_error">N</xsl:element>
						<xsl:element name="ignore_pending_termination">N</xsl:element>
						<xsl:element name="ignore_pending_com_termination">N</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>validate_access_number_range_</xsl:text>
								<xsl:value-of select="position()"/>
							</xsl:element>
							<xsl:element name="field_name">duplicate_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">error_text</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>CCM7002 Ein Dienst mit Rufnummer </xsl:text>
									<xsl:value-of select="request-param[@name='countryCode']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='areaCode']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='localNumber']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='beginNumber']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='endNumber']"/>
									<xsl:text> existiert bereits, und bisher ist keine Kündigung zum </xsl:text>
									<xsl:value-of select="$desiredDate"/>
									<xsl:text> dafür vorgesehen.</xsl:text>									
									<xsl:text>&#xA;Kundennummer: </xsl:text>									
								</xsl:element>							
							</xsl:element>                
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>find_access_number_range_</xsl:text>
									<xsl:value-of select="position()"/>
								</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>&#xA;Dienstenutzung: </xsl:text>									
								</xsl:element>							
							</xsl:element>                
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>find_access_number_range_</xsl:text>
									<xsl:value-of select="position()"/>
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>&#xA;Vertragsnummer: </xsl:text>									
								</xsl:element>							
							</xsl:element>                
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>find_access_number_range_</xsl:text>
									<xsl:value-of select="position()"/>
								</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>      
				
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">raiseError</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text_ref">
							<xsl:element name="command_id">error_text</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>							
						<xsl:element name="ccm_error_code">147002</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>find_access_number_range_</xsl:text>
								<xsl:value-of select="position()"/>
							</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>						
					</xsl:element>
				</xsl:element>								
			</xsl:for-each>

			<!-- do a dummy command to avoid a parsing error in 
				the CcmFifInterface in case of empty lists --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">dummyaction</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">dummyaction</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
