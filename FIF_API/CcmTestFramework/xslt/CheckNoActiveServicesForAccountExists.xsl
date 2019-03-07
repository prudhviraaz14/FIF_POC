		
		<xsl:variable name="ContactText">  
			<xsl:text>Automatisierte Kündigung zum </xsl:text>
			<xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
			<xsl:text> aller Dienste, die mit dem Rechnungskonto </xsl:text>
			<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
			<xsl:text> verknüpft sind.</xsl:text>                      
		</xsl:variable>

		<!-- get account data to retrieve cycle name -->
		<xsl:element name="CcmFifGetAccountDataCmd">
			<xsl:element name="command_id">get_account_data_1</xsl:element>
			<xsl:element name="CcmFifGetAccountDataInCont">
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>
			</xsl:element>    
		</xsl:element>

		<!-- Validate no active services --> 
		<xsl:element name="CcmFifGetMainAccessServicesForAccountCmd">
			<xsl:element name="command_id">validate_no_active_service_1</xsl:element>
			<xsl:element name="CcmFifGetMainAccessServicesForAccountInCont">
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
				</xsl:element>  
				<xsl:element name="effective_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>  
				<xsl:element name="validate_no_service_exists">Y</xsl:element>           
			</xsl:element>
		</xsl:element>
		
		<!-- Create Contact for the Service Termination -->
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">get_account_data_1</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
				<xsl:element name="short_description">Automatische Kündigung</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>Kündigung der Dienste, die mit dem Rechnungskonto </xsl:text>
					<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					<xsl:text> verknüpft sind.</xsl:text>
					<xsl:text>&#xA;Client name : </xsl:text>
					<xsl:value-of select="request-param[@name='clientName']"/>
					<xsl:text>&#xA;TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text>&#xA;User name: </xsl:text>
					<xsl:value-of select="request-param[@name='USER_NAME']"/>				  
				</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- Create external notification -->
		<xsl:element name="CcmFifCreateExternalNotificationCmd">
			<xsl:element name="command_id">create_external_notification_1</xsl:element>
			<xsl:element name="CcmFifCreateExternalNotificationInCont">
				<xsl:element name="effective_date">						
					<xsl:value-of select="$Today"/>					
				</xsl:element>
				<xsl:element name="notification_action_name">createKBANotification</xsl:element>
				<xsl:element name="target_system">KBA</xsl:element>                           				
				<xsl:element name="parameter_value_list">
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>	
						<xsl:element name="parameter_value_ref">
							<xsl:element name="command_id">get_account_data_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">TYPE</xsl:element>
						<xsl:element name="parameter_value">CONTACT</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">CATEGORY</xsl:element>
						<xsl:element name="parameter_value">Termination</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">USER_NAME</xsl:element>
						<xsl:element name="parameter_value">
							<xsl:value-of select="request-param[@name='USER_NAME']"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
						<xsl:element name="parameter_value">CCB</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">WORK_DATE</xsl:element>
						<xsl:element name="parameter_value">								
							<xsl:value-of select="$Today"/>																
						</xsl:element>
					</xsl:element>					
					<xsl:element name="CcmFifParameterValueCont">
						<xsl:element name="parameter_name">TEXT</xsl:element>
						<xsl:element name="parameter_value">
							<xsl:value-of select="$ContactText"/>
						</xsl:element>
					</xsl:element>					
				</xsl:element>
			</xsl:element>
		</xsl:element>
