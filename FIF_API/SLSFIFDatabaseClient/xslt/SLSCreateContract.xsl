<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an Add Service Subscription FIF request

  @author schwarje
-->
<xsl:stylesheet 
    exclude-result-prefixes="dateutils" 
    version="1.0"
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
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">

        <xsl:if test="count(request-param-list[@name='productCommitmentList']/request-param-list-item) != 0
        			and request-param[@name='productCode'] != ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">onlyUseListsOrSimpleParameters</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Bitte productCommitmentList ODER einfache Parameter nutzen, nicht beide.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

        <xsl:if test="request-param[@name='productCode'] = '' and request-param[@name='pricingStructureCode'] != ''
        			or request-param[@name='productCode'] != '' and request-param[@name='pricingStructureCode'] = ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">productAndTariff</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">productCode und pricingStructureCode müssen beide gesetzt sein.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

        <xsl:if test="request-param[@name='createContract'] = 'N' and request-param[@name='contractNumber'] = ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">contractNumberMissing</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Vertragsnummer (contractNumber) muss gesetzt sein, falls kein Vertrag erstellt werden soll.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

        <xsl:if test="request-param[@name='createContract'] != 'Y' and request-param[@name='createProductCommitment'] != 'Y'">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">nothingToDo</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Überflüssige FIF-Transaktion, nichts zu erstellen (createContract = N und createProductCommitment = N).</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

        <xsl:if test="request-param[@name='contractType'] = 'O' and 
        			(request-param[@name='createContract'] != 'Y' or request-param[@name='createProductCommitment'] != 'Y')">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">alwaysCreateOrderForm</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Bei Aufragsformularen muss immer createContract = Y und createProductCommitment = Y gesetzt sein.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>

		<!-- lock product to avoid concurrency problems -->
		<xsl:element name="CcmFifLockObjectCmd">
			<xsl:element name="CcmFifLockObjectInCont">
				<xsl:element name="object_id">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="object_type">CUSTOMER</xsl:element>
			</xsl:element>
		</xsl:element>

		<xsl:choose>
			<xsl:when test="request-param[@name='contractType'] = 'K'">
				<xsl:if test="request-param[@name='createContract'] = 'Y'">
					<!-- Create Skeleton Contract-->		
					<xsl:element name="CcmFifCreateSkeletonContractCmd">
						<xsl:element name="command_id">create_contract</xsl:element>
						<xsl:element name="CcmFifCreateSkeletonContractInCont">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
							<xsl:element name="currency_rd">
								<xsl:value-of select="request-param[@name='currencyRd']"/>
							</xsl:element>
							<xsl:element name="language_rd">
								<xsl:value-of select="request-param[@name='languageRd']"/>
							</xsl:element>
							<xsl:element name="loi_indicator">
								<xsl:value-of select="request-param[@name='loiIndicator']"/>
							</xsl:element>
							<xsl:element name="min_per_dur_value">
								<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
							</xsl:element>
							<xsl:element name="min_per_dur_unit">
								<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
							</xsl:element>												
							<xsl:element name="termination_restriction">
								<xsl:value-of select="request-param[@name='terminationRestriction']"/>
							</xsl:element>
							<xsl:element name="doc_template_name">Vertrag</xsl:element>
							<xsl:element name="sales_org_num_value">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>					
							<xsl:element name="name">
								<xsl:value-of select="request-param[@name='name']"/>
							</xsl:element>
							<xsl:element name="product_commit_list">
								<xsl:for-each select="request-param-list[@name='productCommitmentList']/request-param-list-item">
									<xsl:element name="CcmFifProductCommitCont">								
										<xsl:element name="new_product_code">
											<xsl:value-of select="request-param[@name='productCode']"/>
										</xsl:element>
										<xsl:element name="new_pricing_structure_code">
											<xsl:value-of select="request-param[@name='pricingStructureCode']"/>
										</xsl:element>	
									</xsl:element>
								</xsl:for-each>							
							</xsl:element>						
						</xsl:element>				
					</xsl:element>
					
					<!-- Sign Skeleton Contract -->			
					<xsl:element name="CcmFifSignSkeletonContractCmd">
						<xsl:element name="command_id">sign_skeleton_contract</xsl:element>
						<xsl:element name="CcmFifSignSkeletonContractInCont">
							<xsl:element name="contract_number_ref">
								<xsl:element name="command_id">create_contract</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
							<xsl:element name="board_sign_name">
								<xsl:value-of select="request-param[@name='boardSignName']"/>
							</xsl:element>
							<xsl:element name="board_sign_date">
								<xsl:value-of select="request-param[@name='boardSignDate']"/>
							</xsl:element>
							<xsl:element name="primary_cust_sign_name">
								<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
							</xsl:element>
							<xsl:element name="primary_cust_sign_date">
								<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
							</xsl:element>
							<xsl:element name="secondary_cust_sign_name">
								<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
							</xsl:element>
							<xsl:element name="secondary_cust_sign_date">
								<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			
			</xsl:when>
			<xsl:when test="request-param[@name='contractType'] = 'S'">

				<xsl:if test="request-param[@name='createContract'] = 'Y'">		
					<xsl:element name="CcmFifCreateServiceDelivContCmd">
						<xsl:element name="command_id">create_contract</xsl:element>
						<xsl:element name="CcmFifCreateServiceDelivContInCont">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
							<xsl:element name="language_rd">
								<xsl:value-of select="request-param[@name='languageRd']"/>
							</xsl:element>
							<xsl:element name="loi_indicator">
								<xsl:value-of select="request-param[@name='loiIndicator']"/>
							</xsl:element>											
							<xsl:element name="doc_template_name">Vertrag</xsl:element>		
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>
							</xsl:element>						
							<xsl:element name="name">
								<xsl:value-of select="request-param[@name='name']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			
				<xsl:if test="request-param[@name='createProductCommitment'] = 'Y'">
					<xsl:choose>
						<xsl:when test="count(request-param-list[@name='productCommitmentList']/request-param-list-item) > 0">						
							<xsl:for-each select="request-param-list[@name='productCommitmentList']/request-param-list-item">
								<!-- add SDCPC -->
								<xsl:element name="CcmFifAddSDCProdCommitCmd">
									<xsl:element name="command_id">
										<xsl:text>add_product_commitment_</xsl:text>
										<xsl:value-of select="position()"/>
									</xsl:element>
									<xsl:element name="CcmFifAddSDCProdCommitInCont">
										<xsl:choose>
											<xsl:when test="../../request-param[@name='createContract'] = 'N'">
												<xsl:element name="contract_number">
													<xsl:value-of select="../../request-param[@name='contractNumber']"/>
												</xsl:element>
											</xsl:when>
											<xsl:otherwise>
												<xsl:element name="contract_number_ref">
													<xsl:element name="command_id">create_contract</xsl:element>
													<xsl:element name="field_name">contract_number</xsl:element>
												</xsl:element>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:element name="product_code">
											<xsl:value-of select="request-param[@name='productCode']"/>				
										</xsl:element>
										<xsl:element name="pricing_structure_code">
											<xsl:value-of select="request-param[@name='pricingStructureCode']"/>
										</xsl:element>
										<xsl:element name="notice_per_dur_value">
											<xsl:value-of select="../../request-param[@name='noticePeriodDurationValue']"/>
										</xsl:element>
										<xsl:element name="notice_per_dur_unit">
											<xsl:value-of select="../../request-param[@name='noticePeriodDurationUnit']"/>
										</xsl:element>
										<xsl:element name="term_start_date">
											<xsl:value-of select="../../request-param[@name='minPeriodStartDate']"/>
										</xsl:element>
										<xsl:element name="min_per_dur_value">
											<xsl:value-of select="../../request-param[@name='minPeriodDurationValue']"/>
										</xsl:element>
										<xsl:element name="min_per_dur_unit">
											<xsl:value-of select="../../request-param[@name='minPeriodDurationUnit']"/>
										</xsl:element>
										<xsl:element name="sales_org_num_value">
											<xsl:value-of select="../../request-param[@name='salesOrganisationNumber']"/>
										</xsl:element>
										<xsl:element name="sales_org_num_value_vf">
											<xsl:value-of select="../../request-param[@name='salesOrganisationNumberVF']"/>
										</xsl:element>
										<xsl:element name="termination_restriction">
											<xsl:value-of select="../../request-param[@name='terminationRestriction']"/>
										</xsl:element>
										<xsl:element name="doc_template_name">Vertrag</xsl:element>
										<xsl:element name="assoc_skeleton_cont_num">
											<xsl:value-of select="../../request-param[@name='skeletonContractNumber']"/>
										</xsl:element>
										<xsl:element name="auto_extent_period_value">
											<xsl:value-of select="../../request-param[@name='autoExtentPeriodValue']"/>
										</xsl:element>                         
										<xsl:element name="auto_extent_period_unit">
											<xsl:value-of select="../../request-param[@name='autoExtentPeriodUnit']"/>
										</xsl:element>                         
										<xsl:element name="auto_extension_ind">
											<xsl:value-of select="../../request-param[@name='autoExtensionInd']"/>
										</xsl:element>						
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:when>
						
						<xsl:when test="request-param[@name='pricingStructureCode'] != '' and request-param[@name='productCode'] != '' ">
							<!-- add SDCPC -->
							<xsl:element name="CcmFifAddSDCProdCommitCmd">
								<xsl:element name="command_id">add_product_commitment_1</xsl:element>
								<xsl:element name="CcmFifAddSDCProdCommitInCont">
									<xsl:choose>
										<xsl:when test="request-param[@name='createContract'] = 'N'">
											<xsl:element name="contract_number">
												<xsl:value-of select="request-param[@name='contractNumber']"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="contract_number_ref">
												<xsl:element name="command_id">create_contract</xsl:element>
												<xsl:element name="field_name">contract_number</xsl:element>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:element name="product_code">
										<xsl:value-of select="request-param[@name='productCode']"/>				
									</xsl:element>
									<xsl:element name="pricing_structure_code">
										<xsl:value-of select="request-param[@name='pricingStructureCode']"/>
									</xsl:element>
									<xsl:element name="notice_per_dur_value">
										<xsl:value-of select="request-param[@name='noticePeriodDurationValue']"/>
									</xsl:element>
									<xsl:element name="notice_per_dur_unit">
										<xsl:value-of select="request-param[@name='noticePeriodDurationUnit']"/>
									</xsl:element>
									<xsl:element name="term_start_date">
										<xsl:value-of select="request-param[@name='minPeriodStartDate']"/>
									</xsl:element>
									<xsl:element name="min_per_dur_value">
										<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
									</xsl:element>
									<xsl:element name="min_per_dur_unit">
										<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
									</xsl:element>
									<xsl:element name="sales_org_num_value">
										<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
									</xsl:element>
									<xsl:element name="sales_org_num_value_vf">
										<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
									</xsl:element>
									<xsl:element name="termination_restriction">
										<xsl:value-of select="request-param[@name='terminationRestriction']"/>
									</xsl:element>
									<xsl:element name="doc_template_name">Vertrag</xsl:element>
									<xsl:element name="assoc_skeleton_cont_num">
										<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>
									</xsl:element>
									<xsl:element name="auto_extent_period_value">
										<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
									</xsl:element>                         
									<xsl:element name="auto_extent_period_unit">
										<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
									</xsl:element>                         
									<xsl:element name="auto_extension_ind">
										<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
									</xsl:element>						
								</xsl:element>
							</xsl:element>
						</xsl:when>
						
						<xsl:otherwise>
							<xsl:element name="CcmFifRaiseErrorCmd">
								<xsl:element name="command_id">productAndTariff</xsl:element>
								<xsl:element name="CcmFifRaiseErrorInCont">
									<xsl:element name="error_text">productCode und pricingStructureCode müssen beide gesetzt sein.</xsl:element>
								</xsl:element>                                      
				       		</xsl:element>						
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			
				<xsl:if test="request-param[@name='createContract'] = 'Y'">
					<!-- sign SDC -->
					<xsl:element name="CcmFifSignServiceDelivContCmd">
						<xsl:element name="command_id">sign_sdc</xsl:element>
						<xsl:element name="CcmFifSignServiceDelivContInCont">
							<xsl:element name="contract_number_ref">
								<xsl:element name="command_id">create_contract</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
							<xsl:element name="board_sign_name">
								<xsl:value-of select="request-param[@name='boardSignName']"/>
							</xsl:element>
							<xsl:element name="board_sign_date">
								<xsl:value-of select="request-param[@name='boardSignDate']"/>
							</xsl:element>
							<xsl:element name="primary_cust_sign_name">
								<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
							</xsl:element>
							<xsl:element name="primary_cust_sign_date">
								<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
							</xsl:element>
							<xsl:element name="secondary_cust_sign_name">
								<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
							</xsl:element>
							<xsl:element name="secondary_cust_sign_date">
								<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
							</xsl:element>
							<xsl:element name="ignore_if_signed">Y</xsl:element>	
						</xsl:element>					
					</xsl:element>					
				</xsl:if>
			
				<xsl:if test="request-param[@name='createProductCommitment'] = 'Y'">
					<xsl:choose>
						<xsl:when test="count(request-param-list[@name='productCommitmentList']/request-param-list-item) > 0">						
							<xsl:for-each select="request-param-list[@name='productCommitmentList']/request-param-list-item">
								<!-- sign the newly created SDCPC -->
								<xsl:element name="CcmFifSignSDCProductCommitmentCmd">
									<xsl:element name="command_id">
										<xsl:text>sign_sdc_</xsl:text>
										<xsl:value-of select="position()"/>
									</xsl:element>
									<xsl:element name="CcmFifSignSDCProductCommitmentInCont">
										<xsl:element name="product_commitment_number_ref">
											<xsl:element name="command_id">
												<xsl:text>add_product_commitment_</xsl:text>
												<xsl:value-of select="position()"/>
											</xsl:element>
											<xsl:element name="field_name">product_commitment_number</xsl:element>
										</xsl:element>
										<xsl:element name="board_sign_name">
											<xsl:value-of select="../../request-param[@name='boardSignName']"/>
										</xsl:element>
										<xsl:element name="board_sign_date">
											<xsl:value-of select="../../request-param[@name='boardSignDate']"/>
										</xsl:element>
										<xsl:element name="primary_cust_sign_name">
											<xsl:value-of select="../../request-param[@name='primaryCustSignName']"/>
										</xsl:element>
										<xsl:element name="primary_cust_sign_date">
											<xsl:value-of select="../../request-param[@name='primaryCustSignDate']"/>
										</xsl:element>
										<xsl:element name="secondary_cust_sign_name">
											<xsl:value-of select="../../request-param[@name='secondaryCustSignName']"/>
										</xsl:element>
										<xsl:element name="secondary_cust_sign_date">
											<xsl:value-of select="../../request-param[@name='secondaryCustSignDate']"/>
										</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:when>
						
						<xsl:when test="request-param[@name='pricingStructureCode'] != '' and request-param[@name='productCode'] != '' ">
							<!-- sign the newly created SDCPC -->
							<xsl:element name="CcmFifSignSDCProductCommitmentCmd">
								<xsl:element name="command_id">sign_sdcpc_1</xsl:element>
								<xsl:element name="CcmFifSignSDCProductCommitmentInCont">
									<xsl:element name="product_commitment_number_ref">
										<xsl:element name="command_id">add_product_commitment_1</xsl:element>
										<xsl:element name="field_name">product_commitment_number</xsl:element>
									</xsl:element>
									<xsl:element name="board_sign_name">
										<xsl:value-of select="request-param[@name='boardSignName']"/>
									</xsl:element>
									<xsl:element name="board_sign_date">
										<xsl:value-of select="request-param[@name='boardSignDate']"/>
									</xsl:element>
									<xsl:element name="primary_cust_sign_name">
										<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
									</xsl:element>
									<xsl:element name="primary_cust_sign_date">
										<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
									</xsl:element>
									<xsl:element name="secondary_cust_sign_name">
										<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
									</xsl:element>
									<xsl:element name="secondary_cust_sign_date">
										<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			
			</xsl:when>
			<xsl:when test="request-param[@name='contractType'] = 'O'">
			
				<xsl:choose>
					<xsl:when test="request-param[@name='productCode'] != '' and request-param[@name='pricingStructureCode'] != ''">
						<!-- Create Order Form-->
						<xsl:element name="CcmFifCreateOrderFormCmd">
							<xsl:element name="command_id">create_contract</xsl:element>
							<xsl:element name="CcmFifCreateOrderFormInCont">
								<xsl:element name="customer_number">
									<xsl:value-of select="request-param[@name='customerNumber']"/>
								</xsl:element>
								<xsl:element name="term_start_date">
									<xsl:value-of select="request-param[@name='minPeriodDurationStartDate']"/>
								</xsl:element>
								<xsl:element name="min_per_dur_value">
									<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
								</xsl:element>
								<xsl:element name="min_per_dur_unit">
									<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
								</xsl:element>
								<xsl:element name="sales_org_num_value">
									<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
								</xsl:element>
								<xsl:element name="sales_org_num_value_vf">
									<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
								</xsl:element>
								<xsl:element name="termination_restriction">
									<xsl:value-of select="request-param[@name='terminationRestriction']"/>
								</xsl:element>
								<xsl:element name="doc_template_name">Vertrag</xsl:element>
								<xsl:element name="assoc_skeleton_cont_num">
									<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>
								</xsl:element>
								<xsl:element name="auto_extent_period_value">
									<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
								</xsl:element>                         
								<xsl:element name="auto_extent_period_unit">
									<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
								</xsl:element>                         
								<xsl:element name="auto_extension_ind">
									<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
								</xsl:element>						
								<xsl:element name="name">
									<xsl:value-of select="request-param[@name='name']"/>
								</xsl:element>											
							</xsl:element>
						</xsl:element>
						
						<!-- Add Order Form Product Commitment -->
						<xsl:element name="CcmFifAddProductCommitCmd">
							<xsl:element name="command_id">add_product_commitment_1</xsl:element>
							<xsl:element name="CcmFifAddProductCommitInCont">
								<xsl:element name="customer_number">
									<xsl:value-of select="request-param[@name='customerNumber']"/>
								</xsl:element>
								<xsl:element name="contract_number_ref">
									<xsl:element name="command_id">create_contract</xsl:element>
									<xsl:element name="field_name">contract_number</xsl:element>
								</xsl:element>
								<xsl:element name="product_code">
									<xsl:value-of select="request-param[@name='productCode']"/>
								</xsl:element>
								<xsl:element name="pricing_structure_code">
									<xsl:value-of select="request-param[@name='pricingStructureCode']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<!-- Sign Order Form -->
						<xsl:element name="CcmFifSignOrderFormCmd">
							<xsl:element name="command_id">sign_of</xsl:element>
							<xsl:element name="CcmFifSignOrderFormInCont">
								<xsl:element name="contract_number_ref">
									<xsl:element name="command_id">create_contract</xsl:element>
									<xsl:element name="field_name">contract_number</xsl:element>
								</xsl:element>
								<xsl:element name="board_sign_name">
									<xsl:value-of select="request-param[@name='boardSignName']"/>
								</xsl:element>
								<xsl:element name="board_sign_date">
									<xsl:value-of select="request-param[@name='boardSignDate']"/>
								</xsl:element>
								<xsl:element name="primary_cust_sign_name">
									<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
								</xsl:element>
								<xsl:element name="primary_cust_sign_date">
									<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
								</xsl:element>
								<xsl:element name="secondary_cust_sign_name">
									<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
								</xsl:element>
								<xsl:element name="secondary_cust_sign_date">
									<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:when>
				
					<xsl:otherwise>
						<xsl:element name="CcmFifRaiseErrorCmd">
							<xsl:element name="command_id">productAndTariff</xsl:element>
							<xsl:element name="CcmFifRaiseErrorInCont">
								<xsl:element name="error_text">Out of Cheese Error. Redo From Start. (productCode und pricingStructureCode müssen beide gesetzt sein)</xsl:element>
							</xsl:element>                                      
			       		</xsl:element>        			
					</xsl:otherwise>
				</xsl:choose>
			
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">wrongContractType</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Falscher Vertragstyp (contractType) gewählt, erlaubt sind O (Auftragsformular), S (Dienstleistungsvertrag) und K (Rahmenvertrag).</xsl:element>
					</xsl:element>                                      
	       		</xsl:element>        			
			</xsl:otherwise>		
		</xsl:choose>

		
		<!-- TODO Create Contact -->
		<xsl:if test="request-param[@name='createContact'] != 'N'">
		    <xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">
						<xsl:choose>
							<xsl:when test="request-param[@name='contactTypeRd'] != ''">
								<xsl:value-of select="request-param[@name='contactTypeRd']"/>
							</xsl:when>
							<xsl:otherwise>CONTRACT</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="short_description">
						<xsl:choose>
							<xsl:when test="request-param[@name='shortDescription'] != ''">
								<xsl:value-of select="request-param[@name='shortDescription']"/>
							</xsl:when>
							<xsl:otherwise>Vertrag erstellt</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					
					<xsl:element name="description_text_list">
						<xsl:if test="request-param[@name='longDescriptionText'] != ''">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
					    			<xsl:value-of select="request-param[@name='longDescriptionText']"/>
									<xsl:text>&#xA;</xsl:text>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='createContract'] = 'Y'">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:choose>
										<xsl:when test="request-param[@name='contractType'] = 'K'">Rahmenvertrag </xsl:when>
										<xsl:when test="request-param[@name='contractType'] = 'S'">Dienstleistungsvertrag </xsl:when>
										<xsl:when test="request-param[@name='contractType'] = 'O'">Auftragsformular </xsl:when>
									</xsl:choose>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">create_contract</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>          
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text"> wurde erstellt.&#xA;</xsl:element>
							</xsl:element>														    
						</xsl:if>
						<xsl:if test="request-param[@name='createProductCommitment'] = 'Y' and request-param[@name='contractType'] = 'S'">
							<xsl:choose>
								<xsl:when test="count(request-param-list[@name='productCommitmentList']/request-param-list-item) > 0">						
									<xsl:for-each select="request-param-list[@name='productCommitmentList']/request-param-list-item">
										<xsl:element name="CcmFifPassingValueCont">
											<xsl:element name="contact_text">Serviceschein </xsl:element>
										</xsl:element>
										<xsl:element name="CcmFifCommandRefCont">
											<xsl:element name="command_id">
												<xsl:text>add_product_commitment_</xsl:text>
												<xsl:value-of select="position()"/>
											</xsl:element>
											<xsl:element name="field_name">product_commitment_number</xsl:element>          
										</xsl:element>
										<xsl:element name="CcmFifPassingValueCont">
											<xsl:element name="contact_text">
												<xsl:text>: Produkt </xsl:text>
												<xsl:value-of select="request-param[@name='productCode']"/>
												<xsl:text>, Tarif </xsl:text>
												<xsl:value-of select="request-param[@name='pricingStructureCode']"/>												
												<xsl:text>&#xA;</xsl:text>
											</xsl:element>
										</xsl:element>														    
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="contact_text">Serviceschein </xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">add_product_commitment_1</xsl:element>
										<xsl:element name="field_name">product_commitment_number</xsl:element>          
									</xsl:element>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="contact_text">
											<xsl:text>: Produkt </xsl:text>
											<xsl:value-of select="request-param[@name='productCode']"/>
											<xsl:text>, Tarif </xsl:text>
											<xsl:value-of select="request-param[@name='pricingStructureCode']"/>												
											<xsl:text>&#xA;</xsl:text>
										</xsl:element>
									</xsl:element>														    
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="request-param[@name='contractType'] = 'O'">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>Produkt </xsl:text>
									<xsl:value-of select="request-param[@name='productCode']"/>
									<xsl:text>, Tarif </xsl:text>
									<xsl:value-of select="request-param[@name='pricingStructureCode']"/>												
									<xsl:text>&#xA;</xsl:text>
								</xsl:element>
							</xsl:element>														    
						</xsl:if>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>)</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
