<xsl:if test="request-param[@name='documentPatternAction'] = 'REMOVE' or request-param[@name='documentPatternAction'] = 'ADD'">
	<xsl:if test="request-param[@name='documentPatternAction'] = 'REMOVE'">
		<xsl:element name="CcmFifFindDocumentPatternCmd">
			<xsl:element name="command_id">find_doc_pattern_1</xsl:element>
			<xsl:element name="CcmFifFindDocumentPatternInCont">
				<xsl:element name="supported_object_id">
					<xsl:value-of select="request-param[@name='supportedObjectId']"/>
				</xsl:element>
				<xsl:element name="supported_object_type_rd">
					<xsl:value-of select="request-param[@name='supportedObjectType']"/>
				</xsl:element>
				<xsl:element name="document_template_name">
					<xsl:value-of select="request-param[@name='documentTemplateName']"/>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		<xsl:element name="CcmFifStopDocumentPatternCmd">
			<xsl:element name="command_id">stop_doc_pattern_1</xsl:element>
			<xsl:element name="CcmFifStopDocumentPatternInCont">
				<xsl:element name="document_pattern_id_list_ref">
					<xsl:element name="command_id">find_doc_pattern_1</xsl:element>
					<xsl:element name="field_name">document_pattern_id_list</xsl:element>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>
	<xsl:if test="request-param[@name='documentPatternAction'] = 'ADD'">
		<xsl:element name="CcmFifCreateDocumentPatternCmd">
			<xsl:element name="command_id">createDocumentPattern_1</xsl:element>
			<xsl:element name="CcmFifCreateDocumentPatternInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="$customer_Number"/>
				</xsl:element>
				<xsl:if test="request-param[@name='supportedObjectType'] = 'ACCOUNT'">
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='supportedObjectId']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="mailing_id_ref">
					<xsl:element name="command_id">create_mailing_information</xsl:element>
					<xsl:element name="field_name">mailing_id</xsl:element>
				</xsl:element>
				<xsl:element name="output_device_rd">
					<xsl:value-of select="request-param[@name='outputDevice']"/>
				</xsl:element>
				<xsl:element name="doc_template_name">
					<xsl:value-of select="request-param[@name='documentTemplateName']"/>
				</xsl:element>
				<xsl:element name="currency_rd">
					<xsl:value-of select="request-param[@name='currency']"/>
				</xsl:element>
				<xsl:element name="hierarchy_indicator">
					<xsl:value-of select="request-param[@name='hierarchyIndicator']"/>
				</xsl:element>
				<xsl:element name="language_rd">
					<xsl:value-of select="request-param[@name='language']"/>
				</xsl:element>
				<xsl:element name="zero_suppress_indicator">
					<xsl:value-of select="request-param[@name='zeroSuppressIndicator']"/>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">validate_mailing_id_1</xsl:element>
					<xsl:element name="field_name">success_ind</xsl:element>
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>
	<xsl:if test="request-param[@name='documentPatternAction'] = 'ADD'">
		<xsl:element name="CcmFifCreateDocumentPatternCmd">
			<xsl:element name="command_id">createDocumentPattern_1</xsl:element>
			<xsl:element name="CcmFifCreateDocumentPatternInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="$customer_Number"/>
				</xsl:element>
				<xsl:if test="request-param[@name='supportedObjectType'] = 'ACCOUNT'">
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='supportedObjectId']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="mailing_id_ref">
					<xsl:element name="command_id">Find_mailing_1</xsl:element>
					<xsl:element name="field_name">mailing_id</xsl:element>
				</xsl:element>
				<xsl:element name="output_device_rd">
					<xsl:value-of select="request-param[@name='outputDevice']"/>
				</xsl:element>
				<xsl:element name="doc_template_name">
					<xsl:value-of select="request-param[@name='documentTemplateName']"/>
				</xsl:element>
				<xsl:element name="currency_rd">
					<xsl:value-of select="request-param[@name='currency']"/>
				</xsl:element>
				<xsl:element name="hierarchy_indicator">
					<xsl:value-of select="request-param[@name='hierarchyIndicator']"/>
				</xsl:element>
				<xsl:element name="language_rd">
					<xsl:value-of select="request-param[@name='language']"/>
				</xsl:element>
				<xsl:element name="zero_suppress_indicator">
					<xsl:value-of select="request-param[@name='zeroSuppressIndicator']"/>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">validate_mailing_id_1</xsl:element>
					<xsl:element name="field_name">success_ind</xsl:element>
				</xsl:element>
				<xsl:element name="required_process_ind">N</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>
</xsl:if>
			
