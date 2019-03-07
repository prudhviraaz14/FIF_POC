<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for validating pricing structure code
	
	@author wlazlow
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
			<xsl:variable name="productCode">
				<xsl:choose>
					<!-- new style (all TrxBuilder starting from 1.40) -->
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'lte'">I1208</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'ngn'">I1204</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='accessConfigurationType'] = 'businessIpBitstream'">I1209</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='accessConfigurationType'] = 'ipBitstream'">I1203</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'isdn'">I1100</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'isdnP2P'">I1100</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'lte'">VI208</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'ngn'">VI202</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'ipBitstream'">VI203</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'isdn'">V0002</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'isdnP2P'">V0002</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'ipCentrex'">VI204</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'seat' and 
						request-param[@name='accessType'] = 'ipCentrex'">VI205</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='accessType'] = 'businessDSL'">I1207</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'sipTrunk'">VI211</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'tvCenter'">I1305</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'sip'">VI201</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'mobile'">V8000</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'safetyPackage'">I1410</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'dslr'">I1201</xsl:when>					
					<xsl:when test="
						request-param[@name='accessType'] = 'preselect'">V0001</xsl:when>					
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'businessVoip'">VI214</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="serviceCode">
				<xsl:choose>
					<!-- LTE -->
					<xsl:when test="
						request-param[@name='accessType'] = 'lte' and
						request-param[@name='functionType'] = 'internet'">I1290</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'lte' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voiceBasis'">VI018</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'lte' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voicePremium'">VI019</xsl:when>
					<!-- Bitstream -->
					<xsl:when test="
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='functionType'] = 'internet' and
						request-param[@name='accessConfigurationType'] = 'businessIpBitstream'">I1203</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='functionType'] = 'internet' and
						request-param[@name='accessConfigurationType'] = 'ipBitstream'">I1213</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voiceBasis'">VI009</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voicePremium'">VI006</xsl:when>
					<!-- NGN/FTTx -->
					<xsl:when test="
						request-param[@name='accessType'] = 'ngn' and
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='serviceType'] = 'adslInternet'">I1210</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'ngn' and
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='serviceType'] = 'fttxInternet'">I121z</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'ngn' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voiceBasis'">VI002</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'ngn' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voicePremium'">VI003</xsl:when>					
					<!-- ISDN -->
					<xsl:when test="
						request-param[@name='accessType'] = 'isdn' and
						request-param[@name='functionType'] = 'internet'">I1040</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'isdnP2P' and
						request-param[@name='functionType'] = 'internet'">I1040</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'isdn' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voiceBasis'">V0003</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'isdn' and
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='serviceType'] = 'voicePremium'">V0010</xsl:when>
					<xsl:when test="
						request-param[@name='accessType'] = 'isdnP2P' and
						request-param[@name='functionType'] = 'voice'">V0011</xsl:when>
					<!-- businessDSL -->
					<xsl:when test="
						request-param[@name='serviceType'] = 'adslInternet' and 
						request-param[@name='accessType'] = 'businessDSL'">I1216</xsl:when>
					<xsl:when test="
						request-param[@name='serviceType'] = 'sdslInternet' and 
						request-param[@name='accessType'] = 'businessDSL'">I1215</xsl:when>
					<!-- ipCentrex -->
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'ipCentrex'">VI010</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'seat' and 
						request-param[@name='accessType'] = 'ipCentrex' and 
						request-param[@name='serviceType'] = 'mobileSeat'">VI013</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'seat' and 
						request-param[@name='accessType'] = 'ipCentrex' and 
						request-param[@name='serviceType'] = 'fixedSeat'">VI012</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'seat' and 
						request-param[@name='accessType'] = 'ipCentrex' and 
						request-param[@name='serviceType'] = 'convergedSeat'">VI011</xsl:when>
					<!-- sipTrunk -->
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'sipTrunk'">VI021</xsl:when>
					<!-- tvCenter -->
					<xsl:when test="
						request-param[@name='functionType'] = 'tvCenter'">I1305</xsl:when>
					<!-- VoIP-2nd-Line  -->
					<xsl:when test="
						request-param[@name='accessType'] = 'sip'">VI201</xsl:when>
					<!-- Arcor-Mobile  -->
					<xsl:when test="
						request-param[@name='accessType'] = 'mobile'">V8000</xsl:when>
					<!-- safetyPackage -->
					<xsl:when test="
						request-param[@name='functionType'] = 'safetyPackage'">I1410</xsl:when>					
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'businessVoip'">VI080</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:element name="CcmFifValidatePricingStructureCmd">
				<xsl:element name="command_id">validate_pricing_structure_1</xsl:element>
				<xsl:element name="CcmFifValidatePricingStructureInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="product_code">
						<xsl:value-of select="$productCode"/>
					</xsl:element>
					<xsl:element name="pricing_structure_code">
						<xsl:value-of select="request-param[@name='pricingStructureCode']"/>
					</xsl:element>
					<xsl:element name="classification">
						<xsl:value-of select="request-param[@name='classification']"/>
					</xsl:element>
					<xsl:element name="customer_category">
						<xsl:value-of select="request-param[@name='customerCategory']"/>
					</xsl:element>
					<xsl:if test="count(request-param-list[@name='affinityGroupList']/request-param-list-item) != 0">
						<xsl:element name="affinity_group_list">
							<!-- Pass in the list of affinity groups -->
							<xsl:for-each select="request-param-list[@name='affinityGroupList']/request-param-list-item">
								<xsl:element name="CcmFifPassingValueCont">
									<xsl:element name="value">
										<xsl:value-of select="request-param[@name='affinityGroup']"/>
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_code">
				      <xsl:choose>
					    <xsl:when test="request-param[@name='targetServiceCode'] != ''">
					      <xsl:value-of select="request-param[@name='targetServiceCode']"/>
					    </xsl:when>
					    <xsl:otherwise>
						  <xsl:value-of select="$serviceCode"/>
						</xsl:otherwise>
				      </xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
