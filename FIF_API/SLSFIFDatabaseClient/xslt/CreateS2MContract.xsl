<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an S2M contract

  @author banania
-->

<!DOCTYPE XSL [
<!ENTITY AddFeatureServices SYSTEM "AddS2MFeatureServices.xsl">
<!ENTITY CreateBasicContractData SYSTEM "CreateBasicContractData.xsl">
<!ENTITY CreateAndFetchBasicData SYSTEM "CreateAndFetchBasicData.xsl">
]>

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

		
		<xsl:element name="Command_List">

		    <xsl:variable name="contractName">ISDN S2M</xsl:variable>
		    
			&CreateAndFetchBasicData;
			&CreateBasicContractData;
		
			<xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
			
			<xsl:variable name="ServiceCode">
				<xsl:choose>
					<xsl:when test ="request-param[@name='serviceType'] = 'PRI'">
						<xsl:text>V0012</xsl:text>
					</xsl:when>
					<xsl:when test ="request-param[@name='serviceType'] = 'PRI_FLAT'">
						<xsl:text>V0500</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='serviceCode']"/>
					</xsl:otherwise>
				</xsl:choose>                      
			</xsl:variable>
			

			<!-- Convert the desired date to OPM format -->
			<xsl:variable name="desiredDateOPM"
				select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
			
			<!-- Add Main Service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$ServiceCode"/>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
						<xsl:if test="request-param[@name='accountNumber'] =''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber'] !=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber'] "/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
							<!-- Standort  Addresse -->
							<xsl:if test="request-param[@name='addressId']=''">
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0014</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='addressId']!=''">
								<xsl:element name="CcmFifAddressCharacteristicCont">
									<xsl:element name="service_char_code">V0014</xsl:element>
									<xsl:element name="data_type">ADDRESS</xsl:element>
									<xsl:element name="address_id">
										<xsl:value-of select="request-param[@name='addressId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Old TNB -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0060</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='oldTNB']"/>
								</xsl:element>
							</xsl:element>
							<!-- Carrier -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0081</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Arcor</xsl:element>
							</xsl:element>
							<!-- Carrierschlüssel -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0082</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value"></xsl:element>
							</xsl:element>
							<!-- Prov. Minderung -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0149</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">0%</xsl:element>
							</xsl:element>
							<!-- Gebührenmodell -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0935</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">sekunde</xsl:element>
							</xsl:element>
							<!--  Number of New Access Number -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0936</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='numberOfNewAccessNumber']"/>
								</xsl:element>
							</xsl:element>
							<!--  Aktivierungszeit -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0940</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">12:00</xsl:element>
							</xsl:element>
							<!--  Endkunden_Guiding_Condition -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">GC004</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">alle Calls</xsl:element>
							</xsl:element>													
							<!-- Bemerkung -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0008</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value"></xsl:element>
							</xsl:element>
							<!-- Billing Account Number -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V1002</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='billingAccountNumber']"/>
								</xsl:element>
							</xsl:element>
							<!-- Anschlußnummernbereich -->
							<xsl:if test="request-param[@name='accessNumberRange'] != ''">
								<xsl:element name="CcmFifAccessNumberCont">
									<xsl:element name="service_char_code">V0002</xsl:element>
									<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
									<xsl:element name="masking_digits_rd">
										<xsl:value-of select="$MaskingDigits"/>
									</xsl:element>
									<xsl:element name="retention_period_rd">
										<xsl:value-of select="$RetentionPeriod"/>
									</xsl:element>
									<xsl:element name="storage_masking_digits_rd">
										<xsl:value-of select="$StorageMaskingDigits"/>
									</xsl:element>
									<xsl:element name="country_code">
										<xsl:value-of select="substring-before(request-param[@name='accessNumberRange'], ';')"/>
									</xsl:element>
									<xsl:element name="city_code">
										<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumberRange'],';'), ';')"/>
									</xsl:element>
									<xsl:element name="local_number">
										<xsl:value-of 
											select= "substring-before(substring-after(substring-after(request-param[@name='accessNumberRange'],';'), ';'), ';')"/>
									</xsl:element>
									<xsl:element name="from_ext_num">
										<xsl:value-of 
											select="substring-before(substring-after(substring-after(substring-after(request-param[@name='accessNumberRange'],';'), ';'), ';'), ';')"/>
									</xsl:element>
									<xsl:element name="to_ext_num">
										<xsl:value-of 
											select="substring-after(substring-after(substring-after(substring-after(request-param[@name='accessNumberRange'],';'), ';'), ';'), ';')"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Steuerung über OP -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0018</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">mit OP</xsl:element>
							</xsl:element>
							<!-- Rufnummer (Zentrale) -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0016</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='centralOffice']"/>
								</xsl:element>
							</xsl:element>
							<!-- Anschlußnummernbereich-extra1 -->
							<xsl:if test="request-param[@name='additionalAccessNumberRange1'] != ''">
								<xsl:element name="CcmFifAccessNumberCont">
									<xsl:element name="service_char_code">W9002</xsl:element>
									<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
									<xsl:element name="masking_digits_rd">
										<xsl:value-of select="$MaskingDigits"/>
									</xsl:element>
									<xsl:element name="retention_period_rd">
										<xsl:value-of select="$RetentionPeriod"/>
									</xsl:element>
									<xsl:element name="storage_masking_digits_rd">
										<xsl:value-of select="$StorageMaskingDigits"/>
									</xsl:element>
									<xsl:element name="country_code">
										<xsl:value-of select="substring-before(request-param[@name='additionalAccessNumberRange1'], ';')"/>
									</xsl:element>
									<xsl:element name="city_code">
										<xsl:value-of select="substring-before(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';')"/>
									</xsl:element>
									<xsl:element name="local_number">
										<xsl:value-of 
											select= "substring-before(substring-after(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';'), ';')"/>
									</xsl:element>
									<xsl:element name="from_ext_num">
										<xsl:value-of 
											select="substring-before(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';'), ';'), ';')"/>
									</xsl:element>
									<xsl:element name="to_ext_num">
										<xsl:value-of 
											select="substring-after(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';'), ';'), ';')"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Anschlußnummernbereich-extra2  -->
							<xsl:if test="request-param[@name='additionalAccessNumberRange2'] != ''">
								<xsl:element name="CcmFifAccessNumberCont">
									<xsl:element name="service_char_code">W9003</xsl:element>
									<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
									<xsl:element name="masking_digits_rd">
										<xsl:value-of select="$MaskingDigits"/>
									</xsl:element>
									<xsl:element name="retention_period_rd">
										<xsl:value-of select="$RetentionPeriod"/>
									</xsl:element>
									<xsl:element name="storage_masking_digits_rd">
										<xsl:value-of select="$StorageMaskingDigits"/>
									</xsl:element>
									<xsl:element name="country_code">
										<xsl:value-of select="substring-before(request-param[@name='additionalAccessNumberRange2'], ';')"/>
									</xsl:element>
									<xsl:element name="city_code">
										<xsl:value-of select="substring-before(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';')"/>
									</xsl:element>
									<xsl:element name="local_number">
										<xsl:value-of 
											select= "substring-before(substring-after(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';'), ';')"/>
									</xsl:element>
									<xsl:element name="from_ext_num">
										<xsl:value-of 
											select="substring-before(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';'), ';'), ';')"/>
									</xsl:element>
									<xsl:element name="to_ext_num">
										<xsl:value-of 
											select="substring-after(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';'), ';'), ';')"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  New TNB V0061-->
								<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0061</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value"></xsl:element>
								</xsl:element>
							<!--  Old TNB V0062-->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0062</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value"></xsl:element>
							</xsl:element>							
							<!-- ASB Anschlußbereich-Kennzeichen -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0934</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value"></xsl:element>
							</xsl:element>
							<!-- Bearbeitungsart -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0971</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">TAL</xsl:element>
							</xsl:element>	
							<xsl:if test="$ServiceCode = 'V0014'">
								<!--  Line Owner Last Name -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0127</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='lineOwnerLastName']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="$ServiceCode = 'V0012'">
							<!-- V2024 Umzugsvariante-->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V2024</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">kein Umzug</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Monatspreis S2M-Anschlüsse -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0562</xsl:element>
								<xsl:element name="data_type">DECIMAL</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='monthlyCharge']"/>
								</xsl:element>
							</xsl:element>
							<!-- Steuerung Monatspreis S2M-Anschlüsse -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0563</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='monthlyChargeType']"/>
								</xsl:element>
							</xsl:element>
							<!-- Einrichtungspreises für Primärmultiplexanschlüsse -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0573</xsl:element>
								<xsl:element name="data_type">DECIMAL</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='oneTimeCharge']"/>
								</xsl:element>
							</xsl:element>	
							<!-- Steuerung Einrichtungspreis Primärmultiplex -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0574</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='oneTimeChargeType']"/>
								</xsl:element>
							</xsl:element>		
						    <!-- A0010 Bemerkung Technik -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0010</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='technicianRemarks']"/>
						        </xsl:element>
						    </xsl:element>	
						    <!-- A0020 Ansprechpartner Technik -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0020</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='contactPerson']"/>
						        </xsl:element>
						    </xsl:element>	
						    <!-- A0030 Datum Unterschrift Kunde - allerdings identisch mit primaryCustSignDate -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0030</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="dateutils:createOPMDate(request-param[@name='primaryCustSignDate'])"/>
						        </xsl:element>
						    </xsl:element>	
						    <!-- A0040 Leitungstyp -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0040</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='lineType']"/>
						        </xsl:element>
						    </xsl:element>	
						    <!-- A0060 Eingang BO -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0060</xsl:element>
						        <xsl:element name="data_type">DATE</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='orderReceivedDateBackOffice']"/>
						        </xsl:element>
						    </xsl:element>
						    <!-- Eingang AKS -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0065</xsl:element>
						    	<xsl:element name="data_type">DATE</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='orderReceivedDateAKS']"/>
						        </xsl:element>
						    </xsl:element>
						    <!-- Wunschtermin des Kunden -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0070</xsl:element>
						    	<xsl:element name="data_type">DATE</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='customerDesiredDate']"/>
						        </xsl:element>
						    </xsl:element>		
						    <!-- Wunschtermin ist fix -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">A0075</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='fixedOrderDateIndicator']"/>
						        </xsl:element>
						    </xsl:element>								    
						    <!-- Standort des Anschlusses -->
						    <xsl:element name="CcmFifServiceLocationCont">
						        <xsl:element name="service_char_code">V0015</xsl:element>
						        <xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
						        <xsl:element name="jack_location">
						            <xsl:value-of select="request-param[@name='serviceLocation']"/>
						        </xsl:element>
						    </xsl:element>													
						</xsl:element>						
					</xsl:element>
		</xsl:element>

			<!-- Add additional Services  -->
			&AddFeatureServices;
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>					
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_2</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_3</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_4</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_5</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_6</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_7</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>	
						<xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">
							<xsl:variable name="featureServiceCode" select="request-param[@name='serviceCode']"/>
							<xsl:variable name="addServCommandId">add_ss_</xsl:variable>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:value-of select="concat($addServCommandId, $featureServiceCode)"/>
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:for-each>						
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone Customer Order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber'] != ''">	
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] = ''">					
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>        
				</xsl:element>
			</xsl:element>      

			<!-- Create contact  for Service Addition -->
			<xsl:if test="request-param[@name='oldServiceProvider'] = ''">	
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="command_id">create_contact_1</xsl:element>
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:if test="request-param[@name='customerNumber']=''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber']!=''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
						
						<xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
						<xsl:element name="short_description">
							<xsl:text>S2M contract created.</xsl:text>
						</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>TransactionID: </xsl:text>
							<xsl:value-of select="request-param[@name='transactionID']"/>
							<xsl:text>&#xA;S2M Service has been created on:</xsl:text>
							<xsl:if test="request-param[@name='desiredDate']!=''">
								<xsl:value-of select="request-param[@name='desiredDate']"/>
							</xsl:if>
							<xsl:if test="request-param[@name='desiredDate'] = ''">
								<xsl:value-of select="$today"/>
							</xsl:if>
							<xsl:text>&#xA;User name: </xsl:text>
							<xsl:value-of select="request-param[@name='userName']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Create External notification  if requestListId is  set -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_external_notification_2</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="processed_indicator">Y</xsl:element>
						<xsl:element name="notification_action_name">CreateISDNContract</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">ISDN_SERVICE_SUBSCRIPTION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_service_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_product_subscription_1</xsl:element>
									<xsl:element name="field_name">product_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
