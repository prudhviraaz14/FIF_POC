<xsl:element name="CcmFifCommandList">

	<!-- Copy over transaction ID and action name -->
	<xsl:element name="transaction_id">
		<xsl:value-of select="request-param[@name='transactionID']"/>
	</xsl:element>
	<xsl:element name="client_name">
		<xsl:value-of select="request-param[@name='clientName']"/>
	</xsl:element>
	<xsl:variable name="TopAction" select="//request/action-name"/>
	<xsl:element name="action_name">
		<xsl:value-of select="concat($TopAction, '_default')"/>
	</xsl:element>
	<xsl:element name="override_system_date">
		<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
	</xsl:element>
	
	<xsl:element name="Command_List">
	
		<!-- Terminate or cancle simple services first -->
		&TerminateService_Simple; 
		
		<!-- Terminate VoIP Second Line if any exists -->
		&TerminateServ_VoIP;
		
		<!-- Terminate The Mobile Service if any exists -->
		&TerminateService_Mobile; 
		
		&TerminateServiceByAccount_MOS;
		&TerminateServiceByAccount_PCBackup;
		&TerminateService_TVCenter;	
		
		<!-- Validates if all the services connected to the account have been terminated -->
		&CheckNoActiveServicesForAccountExists;
		
	</xsl:element>
	
</xsl:element>
