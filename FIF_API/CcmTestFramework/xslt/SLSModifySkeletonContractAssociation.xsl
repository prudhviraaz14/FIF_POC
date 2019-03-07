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

        <xsl:if test="count(request-param-list[@name='contractList']/request-param-list-item) != 0
        			and request-param[@name='contractNumber'] != ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">onlyUseListsOrSimpleParameters</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Bitte contractList ODER einfache Parameter nutzen, nicht beide.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

        <xsl:if test="count(request-param-list[@name='contractList']/request-param-list-item) = 0
        			and request-param[@name='contractNumber'] = ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">nothingToDo</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Überflüssige FIF-Transaktion, nichts zu tun (contractNumber und contractList leer).</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/> 

		<xsl:for-each select="request-param-list[@name='contractList']/request-param-list-item">
		
			<!-- get the owning customer for the contract -->
			<xsl:element name="CcmFifGetOwningCustomerCmd">
				<xsl:element name="command_id">get_customer</xsl:element>
				<xsl:element name="CcmFifGetOwningCustomerInCont">
					<xsl:element name="contract_number">
						<xsl:value-of select="request-param[@name='contractNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<!-- lock product to avoid concurrency problems -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id_ref">
						<xsl:element name="command_id">get_customer</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">CUSTOMER</xsl:element>
				</xsl:element>
			</xsl:element>
		
			<xsl:choose>
				<xsl:when test="request-param[@name='contractType'] = 'S'">
	
					<!-- Renegotiate SDC  -->
					<xsl:element name="CcmFifRenegotiateServiceDeliveryContractCmd">
						<xsl:element name="command_id">renegotiate_sdc</xsl:element>
						<xsl:element name="CcmFifRenegotiateServiceDeliveryContractInCont">
							<xsl:element name="contract_number">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
							</xsl:element>
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:choose>
									<xsl:when test="request-param[@name='action'] = 'ADD'">
										<xsl:value-of select="../../request-param[@name='skeletonContractNumber']"/>								
									</xsl:when>
									<xsl:when test="request-param[@name='action'] = 'REMOVE'">**NULL**</xsl:when>
								</xsl:choose>
							</xsl:element>     
						</xsl:element>
					</xsl:element>
	
					<!-- sign SDC -->
					<xsl:element name="CcmFifSignServiceDelivContCmd">
						<xsl:element name="command_id">sign_sdc</xsl:element>
						<xsl:element name="CcmFifSignServiceDelivContInCont">
							<xsl:element name="contract_number">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
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
				
				</xsl:when>
				<xsl:when test="request-param[@name='contractType'] = 'O'">
				
					<!-- Renegotiate Order Form  -->
					<xsl:element name="CcmFifRenegotiateOrderFormCmd">
						<xsl:element name="command_id">renegotiate_order_form</xsl:element>
						<xsl:element name="CcmFifRenegotiateOrderFormInCont">
							<xsl:element name="contract_number">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
							</xsl:element>
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:choose>
									<xsl:when test="request-param[@name='action'] = 'ADD'">
										<xsl:value-of select="../../request-param[@name='skeletonContractNumber']"/>								
									</xsl:when>
									<xsl:when test="request-param[@name='action'] = 'REMOVE'">**NULL**</xsl:when>
								</xsl:choose>
							</xsl:element>     
							<xsl:element name="override_restriction">Y</xsl:element>               
						</xsl:element>
					</xsl:element>
	
					<!-- Sign and Apply -->
					<xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
						<xsl:element name="command_id">sign_apply_1</xsl:element>
						<xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
							<xsl:element name="supported_object_id">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
							</xsl:element>
							<xsl:element name="supported_object_type_rd">
								<xsl:value-of select="request-param[@name='contractType']"/>
							</xsl:element>
							<xsl:element name="apply_swap_date">
								<xsl:value-of select="$tomorrow"/>
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
											
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">wrongContractType</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">Falscher Vertragstyp (contractType) gewählt, erlaubt sind O (Auftragsformular) und S (Dienstleistungsvertrag).</xsl:element>
						</xsl:element>                                      
		       		</xsl:element>        							
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

		<xsl:if test="request-param[@name='contractNumber'] != ''">		
			<!-- get the owning customer for the contract -->
			<xsl:element name="CcmFifGetOwningCustomerCmd">
				<xsl:element name="command_id">get_customer</xsl:element>
				<xsl:element name="CcmFifGetOwningCustomerInCont">
					<xsl:element name="contract_number">
						<xsl:value-of select="request-param[@name='contractNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<!-- lock product to avoid concurrency problems -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id_ref">
						<xsl:element name="command_id">get_customer</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">CUSTOMER</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<xsl:choose>
				<xsl:when test="request-param[@name='contractType'] = 'S'">
	
					<!-- Renegotiate SDC  -->
					<xsl:element name="CcmFifRenegotiateServiceDeliveryContractCmd">
						<xsl:element name="command_id">renegotiate_sdc</xsl:element>
						<xsl:element name="CcmFifRenegotiateServiceDeliveryContractInCont">
							<xsl:element name="contract_number">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
							</xsl:element>
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:choose>
									<xsl:when test="request-param[@name='action'] = 'ADD'">
										<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>								
									</xsl:when>
									<xsl:when test="request-param[@name='action'] = 'REMOVE'">**NULL**</xsl:when>
								</xsl:choose>
							</xsl:element>     
						</xsl:element>
					</xsl:element>
	
					<!-- sign SDC -->
					<xsl:element name="CcmFifSignServiceDelivContCmd">
						<xsl:element name="command_id">sign_sdc</xsl:element>
						<xsl:element name="CcmFifSignServiceDelivContInCont">
							<xsl:element name="contract_number">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
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
				<xsl:when test="request-param[@name='contractType'] = 'O'">
				
					<!-- Renegotiate Order Form  -->
					<xsl:element name="CcmFifRenegotiateOrderFormCmd">
						<xsl:element name="command_id">renegotiate_order_form</xsl:element>
						<xsl:element name="CcmFifRenegotiateOrderFormInCont">
							<xsl:element name="contract_number">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
							</xsl:element>
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:choose>
									<xsl:when test="request-param[@name='action'] = 'ADD'">
										<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>								
									</xsl:when>
									<xsl:when test="request-param[@name='action'] = 'REMOVE'">**NULL**</xsl:when>
								</xsl:choose>
							</xsl:element>     
							<xsl:element name="override_restriction">Y</xsl:element>               
						</xsl:element>
					</xsl:element>
	
					<!-- Sign and Apply -->
					<xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
						<xsl:element name="command_id">sign_apply_1</xsl:element>
						<xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
							<xsl:element name="supported_object_id">
								<xsl:value-of select="request-param[@name='contractNumber']"/>
							</xsl:element>
							<xsl:element name="supported_object_type_rd">
								<xsl:value-of select="request-param[@name='contractType']"/>
							</xsl:element>
							<xsl:element name="apply_swap_date">
								<xsl:value-of select="$tomorrow"/>
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
						<xsl:element name="command_id">wrongContractType</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">Falscher Vertragstyp (contractType) gewählt, erlaubt sind O (Auftragsformular) und S (Dienstleistungsvertrag).</xsl:element>
						</xsl:element>                                      
		       		</xsl:element>        							
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>		

		<!-- Create Contact -->
		<xsl:if test="request-param[@name='createContact'] != 'N'">
		    <xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_customer</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
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
							<xsl:otherwise>Rahmenvertrag geändert</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					
					<xsl:element name="description_text_list">
						
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:if test="request-param[@name='longDescriptionText'] != ''">
					    			<xsl:value-of select="request-param[@name='longDescriptionText']"/>
									<xsl:text>&#xA;</xsl:text>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="request-param[@name='contractNumber'] != ''">
										<xsl:choose>
											<xsl:when test="request-param[@name='contractType'] = 'S'">Dienstleistungsvertrag </xsl:when>
											<xsl:when test="request-param[@name='contractType'] = 'O'">Auftragsformular </xsl:when>
										</xsl:choose>
										<xsl:value-of select="request-param[@name='contractNumber']"/>
									 	<xsl:text> wurde dem Rahmenvertrag </xsl:text>
									 	<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>
									 	<xsl:choose>
									 		<xsl:when test="request-param[@name='action'] = 'ADD'"> hinzugefügt.&#xA;</xsl:when>
									 		<xsl:when test="request-param[@name='action'] = 'REMOVE'"> entfernt.&#xA;</xsl:when>
									 	</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="request-param-list[@name='contractList']/request-param-list-item">
											<xsl:choose>
												<xsl:when test="request-param[@name='contractType'] = 'S'">Dienstleistungsvertrag </xsl:when>
												<xsl:when test="request-param[@name='contractType'] = 'O'">Auftragsformular </xsl:when>
											</xsl:choose>
											<xsl:value-of select="request-param[@name='contractNumber']"/>
										 	<xsl:text> wurde dem Rahmenvertrag </xsl:text>
										 	<xsl:value-of select="../../request-param[@name='skeletonContractNumber']"/>
										 	<xsl:choose>
										 		<xsl:when test="request-param[@name='action'] = 'ADD'"> hinzugefügt.&#xA;</xsl:when>
										 		<xsl:when test="request-param[@name='action'] = 'REMOVE'"> entfernt.&#xA;</xsl:when>
										 	</xsl:choose>
										</xsl:for-each>									
									</xsl:otherwise>								
								</xsl:choose>
							 </xsl:element>
						</xsl:element>														    
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
