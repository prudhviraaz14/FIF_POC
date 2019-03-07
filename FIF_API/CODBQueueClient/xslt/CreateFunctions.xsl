<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a LTE Voice contract

  @author banania 
-->

<!DOCTYPE XSL [

<!ENTITY CSCMapping SYSTEM "CSCMapping.xsl">
<!ENTITY CSCMapping_LTEInternet SYSTEM "CSCMapping_LTEInternet.xsl">
<!ENTITY CSCMapping_LTEVoice SYSTEM "CSCMapping_LTEVoice.xsl">
<!ENTITY CSCMapping_BitDSL SYSTEM "CSCMapping_BitDSL.xsl">
<!ENTITY CSCMapping_BitVoIP SYSTEM "CSCMapping_BitVoIP.xsl">
<!ENTITY CSCMapping_NGNDSL SYSTEM "CSCMapping_NGNDSL.xsl">
<!ENTITY CSCMapping_NGNVoIP SYSTEM "CSCMapping_NGNVoIP.xsl">
<!ENTITY CSCMapping_ISDN SYSTEM "CSCMapping_ISDN.xsl">
<!ENTITY CSCMapping_ISDNDSL SYSTEM "CSCMapping_ISDNDSL.xsl">
<!ENTITY CSCMapping_BusinessDSL SYSTEM "CSCMapping_BusinessDSL.xsl">
<!ENTITY CSCMapping_IPCentrexSite SYSTEM "CSCMapping_IPCentrexSite.xsl">
<!ENTITY CSCMapping_IPCentrexSeat SYSTEM "CSCMapping_IPCentrexSeat.xsl">
<!ENTITY CSCMapping_SIPTrunk SYSTEM "CSCMapping_SIPTrunk.xsl">
<!ENTITY CSCMapping_OneNetBusiness SYSTEM "CSCMapping_OneNetBusiness.xsl">
<!ENTITY CSCMapping_TVCenter SYSTEM "CSCMapping_TVCenter.xsl">
<!ENTITY CSCMapping_VoIP2ndLine SYSTEM "CSCMapping_VoIP2ndLine.xsl">
<!ENTITY CSCMapping_Online SYSTEM "CSCMapping_Online.xsl">
<!ENTITY CSCMapping_Mobile SYSTEM "CSCMapping_Mobile.xsl">
<!ENTITY CSCMapping_SafetyPackage SYSTEM "CSCMapping_SafetyPackage.xsl">
<!ENTITY CSCMapping_ISDNP2P SYSTEM "CSCMapping_ISDNP2P.xsl">
<!ENTITY CSCMapping_ISDNS2M SYSTEM "CSCMapping_ISDNS2M.xsl">
<!ENTITY CSCMapping_AddressCreation SYSTEM "CSCMapping_AddressCreation.xsl">
<!ENTITY ContractCreation_DataRetrieval SYSTEM "ContractCreation_DataRetrieval.xsl">
<!ENTITY ContractCreation_OutputParameters SYSTEM "ContractCreation_OutputParameters.xsl">
<!ENTITY CSCMapping_BusinessInternetRegio SYSTEM "CSCMapping_BusinessInternetRegio.xsl">
<!ENTITY CSCMapping_BusinessVoIP SYSTEM "CSCMapping_BusinessVoIP.xsl">
<!ENTITY CSCMapping_FibreInternet SYSTEM "CSCMapping_FibreInternet.xsl">
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
			
			<xsl:variable name="accessType">
				<xsl:value-of select="request-param[@name='accessType']"/>
			</xsl:variable>
			<xsl:variable name="functionType">
				<xsl:value-of select="request-param[@name='functionType']"/>
			</xsl:variable>
			<xsl:variable name="serviceType">
				<xsl:value-of select="request-param[@name='serviceType']"/>
			</xsl:variable>
			<xsl:variable name="dslBandwidth">
				<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
					request-param[@name='parameterName'] = 'DSLBandwidth']
					/request-param[@name='configuredValue']" />
			</xsl:variable>			
			<xsl:variable name="vectoringIndicator">
				<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
					request-param[@name='parameterName'] = 'vectoringIndicator']
					/request-param[@name='configuredValue']" />
			</xsl:variable>			
			<xsl:variable name="phoneSystemType">
				<xsl:choose>
					<xsl:when test="request-param-list[@name='parameterList']/request-param-list-item[
						request-param[@name='parameterName'] = 'phoneSystemType']
						/request-param[@name='configuredValue'] != ''">
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
							request-param[@name='parameterName'] = 'phoneSystemType']
							/request-param[@name='configuredValue']" />						
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
							request-param[@name='parameterName'] = 'phoneSystemType']
							/request-param[@name='existingValue']" />						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="oneNetId">
				<xsl:choose>
					<xsl:when test="request-param-list[@name='parameterList']/request-param-list-item[
						request-param[@name='parameterName'] = 'oneNetId']
						/request-param[@name='configuredValue'] != ''">
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
							request-param[@name='parameterName'] = 'oneNetId']
							/request-param[@name='configuredValue']" />						
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
							request-param[@name='parameterName'] = 'oneNetId']
							/request-param[@name='existingValue']" />						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="siteID">
				<xsl:choose>
					<xsl:when test="request-param-list[@name='parameterList']/request-param-list-item[
						request-param[@name='parameterName'] = 'siteID']
						/request-param[@name='configuredValue'] != ''">
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
							request-param[@name='parameterName'] = 'siteID']
							/request-param[@name='configuredValue']" />						
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
							request-param[@name='parameterName'] = 'siteID']
							/request-param[@name='existingValue']" />						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- indicates, what the Business-DSL function belongs to (only for businessDSL-internet) -->
			<xsl:variable name="technology">
				<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
					request-param[@name='parameterName'] = 'technology']/request-param[@name='configuredValue']" />						
			</xsl:variable>

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
			    		request-param[@name='accessType'] = 'ipBitstream'and
			    		request-param[@name='accessConfigurationType'] != 'businessIpBitstream'">I1203</xsl:when>
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
			    		request-param[@name='accessType'] = 'isdnS2M'">V0002</xsl:when>
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
			    		request-param[@name='functionType'] = 'internet' and 
			    		request-param[@name='accessType'] = 'businessDSLProfi'">I0504</xsl:when>
			    	<xsl:when test="
			    		request-param[@name='functionType'] = 'voice' and 
			    		request-param[@name='accessType'] = 'sipTrunk'">VI211</xsl:when>
			    	<xsl:when test="
			    		request-param[@name='functionType'] = 'voice' and 
			    		request-param[@name='accessType'] = 'oneNetBusiness'">VI207</xsl:when>
			    	<xsl:when test="
			    		request-param[@name='functionType'] = 'tvCenter'">I1305</xsl:when>
			    	<xsl:when test="
			    		request-param[@name='accessType'] = 'sip'">VI201</xsl:when>
			    	<xsl:when test="
			    		request-param[@name='accessType'] = 'mobile'">V8000</xsl:when>
			    	<xsl:when test="
			    		request-param[@name='functionType'] = 'safetyPackage'">I1410</xsl:when>
					<xsl:when test="
		    		request-param[@name='functionType'] = 'voice' and 
		    		request-param[@name='accessType'] = 'businessVoip'">VI214</xsl:when>
			    	<xsl:otherwise>unknown</xsl:otherwise>
			    </xsl:choose>
			</xsl:variable>
			
	       <xsl:variable name="AutoExtentPeriodValue">	
			  <xsl:choose>
				<xsl:when test="$productCode = 'I1208'
					or $productCode = 'I1204'
					or $productCode = 'I1203'
					or $productCode = 'I1100'
					or $productCode = 'VI208'
					or $productCode = 'VI202'
					or $productCode = 'VI203'
					or $productCode = 'V0002'
					or $productCode = 'V8000'
					or $productCode = 'I1305'
					or $productCode = 'I1410'">	
					<xsl:choose>
						<xsl:when test="request-param[@name='autoExtentPeriodValue'] != ''">			
							<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>				
						</xsl:when>
						<xsl:when test="$productCode = 'I1410' and 
							request-param[@name='autoExtentPeriodValue'] = '' and
							request-param[@name='minPeriodDurationValue'] = '0'">
							<xsl:text>0</xsl:text>
						</xsl:when>
						<xsl:when test="$productCode = 'I1410' and 
							request-param[@name='autoExtentPeriodValue'] = '' and
							request-param[@name='minPeriodDurationValue'] != '0'">
							<xsl:text>1</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>12</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
				</xsl:otherwise>
			  </xsl:choose>	   
	       </xsl:variable>			
			
		   <xsl:variable name="AutoExtentPeriodUnit">	
				<xsl:choose>
					<xsl:when test="$productCode = 'I1208' 
						or $productCode = 'I1204'
						or $productCode = 'I1203'
						or $productCode = 'I1100'
						or $productCode = 'VI208'
						or $productCode = 'VI202'
						or $productCode = 'VI203'
						or $productCode = 'V0002'
						or $productCode = 'V8000'
						or $productCode = 'I1305'
						or $productCode = 'I1410'">	
						<xsl:choose>
							<xsl:when test="request-param[@name='autoExtentPeriodUnit'] != ''">			
								<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>				
							</xsl:when>
							<xsl:when test="$productCode = 'I1410' and 
								request-param[@name='autoExtentPeriodUnit'] = '' and
								request-param[@name='minPeriodDurationValue'] = '0'">
								<xsl:text>MONTH</xsl:text>
							</xsl:when>
							<xsl:when test="$productCode = 'I1410' and 
								request-param[@name='autoExtentPeriodUnit'] = '' and
								request-param[@name='minPeriodDurationValue'] != '0'">
								<xsl:text>MONTH</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>MONTH</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
					</xsl:otherwise>
				</xsl:choose>	   
		    </xsl:variable>						

		    <xsl:variable name="AutoExtensionInd">	
				<xsl:choose>
					<xsl:when test="$productCode = 'I1208' 
						or $productCode = 'I1204'
						or $productCode = 'I1203'
						or $productCode = 'I1100'
						or $productCode = 'VI208'
						or $productCode = 'VI202'
						or $productCode = 'VI203'
						or $productCode = 'V0002'
						or $productCode = 'V8000'
						or $productCode = 'I1305'
						or $productCode = 'I1410'">	
						<xsl:choose>
							<xsl:when test="request-param[@name='autoExtensionInd'] != ''">			
								<xsl:value-of select="request-param[@name='autoExtensionInd']"/>				
							</xsl:when>
							<xsl:when test="$productCode = 'I1410' and 
								request-param[@name='autoExtensionInd'] = '' and
								request-param[@name='minPeriodDurationValue'] = '0'">
								<xsl:text>N</xsl:text>
							</xsl:when>
							<xsl:when test="$productCode = 'I1410' and 
								request-param[@name='autoExtensionInd'] = '' and
								request-param[@name='minPeriodDurationValue'] != '0'">
								<xsl:text>Y</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Y</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
					</xsl:otherwise>
				</xsl:choose>	   
		    </xsl:variable>		
			
		    <xsl:variable name="NoticePeriodDurationValue">3</xsl:variable>					
			<xsl:variable name="NoticePeriodDurationUnit">MONTH</xsl:variable>		

			<xsl:variable name="contractName">	
				<xsl:choose>
					<xsl:when test="$productCode = 'I1208'">LTE-Internet</xsl:when>
					<xsl:when test="$productCode = 'I1204' and 
						request-param[@name='serviceType'] = 'fttxInternet'">FTTx-DSL</xsl:when>
					<xsl:when test="$productCode = 'I1204' and 
						request-param[@name='serviceType'] = 'fibreInternet'">NGN-Glasfaser</xsl:when>
					<xsl:when test="$productCode = 'I1204' and 
						request-param[@name='serviceType'] != 'fttxInternet'">NGN-DSL</xsl:when>
					<xsl:when test="$productCode = 'I1203'">Bitstrom-DSL</xsl:when>
					<xsl:when test="$productCode = 'I1100'">ISDN-Online</xsl:when>
					<xsl:when test="$productCode = 'VI208'">LTE-Voice</xsl:when>
					<xsl:when test="$productCode = 'VI202'">NGN-VoIP</xsl:when>
					<xsl:when test="$productCode = 'VI203'">Bitstrom-VoIP</xsl:when>
					<xsl:when test="$productCode = 'V0002'">ISDN</xsl:when>
					<xsl:when test="$productCode = 'VI204'">IP-Centrex-Site</xsl:when>
					<xsl:when test="$productCode = 'VI205'">IP-Centrex-Seat</xsl:when>
					<xsl:when test="$productCode = 'VI211'">SIP-Trunk</xsl:when>
					<xsl:when test="$productCode = 'VI207'">OneNet Business-Site</xsl:when>
					<xsl:when test="$productCode = 'I1207' and 
						request-param[@name='serviceType'] = 'sdslInternet'">SDSL</xsl:when>
					<xsl:when test="$productCode = 'I1207' and 
						request-param[@name='serviceType'] = 'adslInternet'">Business-DSL</xsl:when>
					<xsl:when test="$productCode = 'I1207' and 
						request-param[@name='serviceType'] = 'fibreInternet'">Business-Glasfaser</xsl:when>
					<xsl:when test="$productCode = 'I0504'">Business-DSL-Profi</xsl:when>
					<xsl:when test="$productCode = 'I1305'">TV-Center</xsl:when>
					<xsl:when test="$productCode = 'VI201'">VoIP-2ndLine</xsl:when>
					<xsl:when test="$productCode = 'V8000'">MoreConnect</xsl:when>
					<xsl:when test="$productCode = 'I1410'">Sicherheitspaket</xsl:when>
					<xsl:when test="$productCode = 'I1209'">BusinessInternetRegio</xsl:when>
					<xsl:when test="$productCode = 'VI214'">Business-Voip</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>			
		
		   <xsl:variable name="orderDate">
            <xsl:if test="request-param[@name='reason'] = 'RELOCATION'
                           or request-param[@name='reason'] = 'PRODUCT_CHANGE'
                           or request-param[@name='reason'] = 'PRODCHANGE_BAS'
                           or request-param[@name='reason'] = 'PRODCHANGE_PREM'">
               <xsl:value-of select="request-param[@name='somDate']"/>
            </xsl:if>
         </xsl:variable>					

            &ContractCreation_DataRetrieval;
			
			<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
			    <xsl:choose>
			        <xsl:when test="$productCode = 'I1208'">
			            &CSCMapping_LTEInternet;
			            &CSCMapping_AddressCreation;
			        </xsl:when> 
			        <xsl:when test="$productCode = 'I1204' and request-param[@name='serviceType'] = 'fibreInternet'">
			            &CSCMapping_FibreInternet;
			            &CSCMapping_AddressCreation;
			        </xsl:when>
			        <xsl:when test="$productCode = 'I1204'">
			            &CSCMapping_NGNDSL;
			            &CSCMapping_AddressCreation;
			        </xsl:when>
			        <xsl:when test="$productCode = 'I1203'">
			            &CSCMapping_BitDSL;
			            &CSCMapping_AddressCreation;
			        </xsl:when>
			        <xsl:when test="$productCode = 'I1100'">
			            &CSCMapping_Online;
			            &CSCMapping_AddressCreation;
			        </xsl:when>
			        <xsl:when test="$productCode = 'VI208'">
			            &CSCMapping_LTEVoice;
			            &CSCMapping_AddressCreation;
			        </xsl:when>
			        <xsl:when test="$productCode = 'VI202'">
			            &CSCMapping_NGNVoIP;
			            &CSCMapping_AddressCreation;
			        </xsl:when>
			    	<xsl:when test="$productCode = 'VI203'">
			    		&CSCMapping_BitVoIP;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$accessType = 'isdnP2P' and $functionType = 'voice'">
			    		&CSCMapping_ISDNP2P;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$accessType = 'isdnS2M' and $functionType = 'voice'">
			    		&CSCMapping_ISDNS2M;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$accessType = 'isdn' and $functionType = 'voice'">
			    		&CSCMapping_ISDN;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'I1207' and request-param[@name='serviceType'] = 'fibreInternet'">
			    		&CSCMapping_FibreInternet;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'I1207'">
			    		&CSCMapping_BusinessDSL;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'I0504'">
			    		&CSCMapping_BusinessDSL;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'VI204'">
			    		&CSCMapping_IPCentrexSite;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'VI205'">
			    		&CSCMapping_IPCentrexSeat;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'VI211'">
			    		&CSCMapping_SIPTrunk;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>			    	
			    	<xsl:when test="$productCode = 'VI207'">
			    		&CSCMapping_OneNetBusiness;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>			    	
			    	<xsl:when test="$productCode = 'I1305'">
			    		&CSCMapping_TVCenter;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'VI201'">
			    		&CSCMapping_VoIP2ndLine;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'V8000'">
			    		&CSCMapping_Mobile;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'I1410'">
			    		&CSCMapping_SafetyPackage;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    	<xsl:when test="$productCode = 'I1209'">
						&CSCMapping_BusinessInternetRegio;
						&CSCMapping_AddressCreation;
					</xsl:when>
					<xsl:when test="$productCode = 'VI214'">
			    		&CSCMapping_BusinessVoIP;
			    		&CSCMapping_AddressCreation;
			    	</xsl:when>
			    </xsl:choose>
			</xsl:for-each>
						
			<xsl:variable name="mainAccessServiceCode">
				<xsl:choose>
					<!-- new style (all TrxBuilder starting from 1.40) -->
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
						request-param[@name='accessConfigurationType'] != 'businessIpBitstream'">I1213</xsl:when>
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
						request-param[@name='functionType'] = 'internet' and 
						request-param[@name='serviceType'] = 'fibreInternet'">I1209</xsl:when>
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
					<xsl:when test="
						request-param[@name='accessType'] = 'isdnS2M' and
						request-param[@name='functionType'] = 'voice'">V0012</xsl:when>
					<!-- businessDSL -->
					<xsl:when test="
						request-param[@name='serviceType'] = 'adslInternet' and 
						request-param[@name='accessType'] = 'businessDSL'">I1216</xsl:when>
					<xsl:when test="
						request-param[@name='serviceType'] = 'sdslInternet' and 
						request-param[@name='accessType'] = 'businessDSL'">I1215</xsl:when>
					<xsl:when test="
						request-param[@name='serviceType'] = 'fibreInternet' and 
						request-param[@name='accessType'] = 'businessDSL'">I1207</xsl:when>
					<!-- businessDSLProfi -->
					<xsl:when test="request-param[@name='accessType'] = 'businessDSLProfi'">
						<!-- TODO for next phase: works only with configured bandwidth! -->
						<xsl:value-of select="$dslBandwidth"/>
					</xsl:when>
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
						request-param[@name='accessType'] = 'sipTrunk' and
						$phoneSystemType != 'S0-A'">VI021</xsl:when>
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'sipTrunk' and
						$phoneSystemType = 'S0-A'">VI020</xsl:when>
					<!-- businessInternetRegio -->
					<xsl:when test="
						request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='accessConfigurationType'] = 'businessIpBitstream' and
						request-param[@name='functionType'] = 'internet'">I1203</xsl:when>
					<!-- oneNetBusiness -->
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'oneNetBusiness'">VI250</xsl:when>
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
					<!-- Business Voip -->
					<xsl:when test="
						request-param[@name='functionType'] = 'voice' and 
						request-param[@name='accessType'] = 'businessVoip'">VI080</xsl:when>
					
					
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="reasonRd">	
				<xsl:choose>
					<xsl:when test="request-param[@name='reason'] != ''">
						<xsl:value-of select="request-param[@name='reason']"/>
					</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1290'">CREATE_LTEDSL</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI018' or
						$mainAccessServiceCode = 'VI019'">CREATE_LTEVOICE</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1210' or
						$mainAccessServiceCode = 'I121z'">CREATE_NGN_DSL</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI002' or
						$mainAccessServiceCode = 'VI003'">CREATE_NGN_VOIP</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1213'">CREATE_BIT_DSL</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI006' or
						$mainAccessServiceCode = 'VI009'">CREATE_BIT_VOIP</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1040'">CREATE_ONL</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'V0003' or
						$mainAccessServiceCode = 'V0010' or
						$mainAccessServiceCode = 'V0011' or
						$mainAccessServiceCode = 'V0012'">CREATE_ISDN</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI011' or
						$mainAccessServiceCode = 'VI012' or 
						$mainAccessServiceCode = 'VI013'">CREATE_IPCSEAT</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI010'">CREATE_IPCSITE</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1215' or
						$mainAccessServiceCode = 'I1216'">CREATE_SDSL</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI020' or
						$mainAccessServiceCode = 'VI021'">CREATE_SIPTRUNK</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI250'">CREATE_ONB</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1305'">ADD_TV_CENTER</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI201'">UPGRADE_VOIP</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'V8000'">CREATE_MOBILE</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1410'">CREATE_SECURITY</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1203'">ADD_BIR</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'VI080'">CREATE_BVOIP</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1209'">ADD_FIBRE_NGN</xsl:when>
					<xsl:when test="
						$mainAccessServiceCode = 'I1207'">ADD_FIBRE_BDSL</xsl:when>
					<xsl:otherwise>CUST_REQUEST</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="detailedReason">
				<xsl:choose>
					<xsl:when test="request-param[@name='detailedReason'] != ''">
						<xsl:value-of select="request-param[@name='detailedReason']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$reasonRd"/>
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:variable>
			
			<!-- Add business DSL main service Subscription -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_main_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:value-of select="$mainAccessServiceCode"/>
					</xsl:element>
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="$reasonRd"/>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
					<xsl:element name="order_date">
						<xsl:value-of select="$orderDate"/>
					</xsl:element>
					<xsl:element name="use_current_pc_version">Y</xsl:element>
					<xsl:element name="service_characteristic_list">
						
						<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
						    <xsl:choose>
						        <xsl:when test="$productCode = 'I1208'">
						            &CSCMapping_LTEInternet;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'I1204' and $mainAccessServiceCode = 'I1209'">
						            &CSCMapping_FibreInternet;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'I1204'">
						            &CSCMapping_NGNDSL;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'I1203'">
						            &CSCMapping_BitDSL;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'I1100'">
						            &CSCMapping_Online;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'VI208'">
						            &CSCMapping_LTEVoice;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'VI202'">
						            &CSCMapping_NGNVoIP;
						            &CSCMapping;
						        </xsl:when>
						        <xsl:when test="$productCode = 'VI203'">
						            &CSCMapping_BitVoIP;
						            &CSCMapping;
						        </xsl:when>
						    	<xsl:when test="$accessType = 'isdnP2P' and $functionType = 'voice'">
						    		&CSCMapping_ISDNP2P;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$accessType = 'isdnS2M' and $functionType = 'voice'">
						    		&CSCMapping_ISDNS2M;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$accessType = 'isdn' and $functionType = 'voice'">
						    		&CSCMapping_ISDN;
						    		&CSCMapping;
						    	</xsl:when>
						      <xsl:when test="$productCode = 'I1207' and $mainAccessServiceCode = 'I1207'">
						          &CSCMapping_FibreInternet;
						          &CSCMapping;
						      </xsl:when>
						    	<xsl:when test="$productCode = 'I1207'">
						    		&CSCMapping_BusinessDSL;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'I0504'">
						    		&CSCMapping_BusinessDSL;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'VI204'">
						    		&CSCMapping_IPCentrexSite;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'VI205'">
						    		&CSCMapping_IPCentrexSeat;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'VI211'">
						    		&CSCMapping_SIPTrunk;
						    		&CSCMapping;
						    	</xsl:when>			    	
						    	<xsl:when test="$productCode = 'VI207'">
						    		&CSCMapping_OneNetBusiness;
						    		&CSCMapping;
						    	</xsl:when>			    	
						    	<xsl:when test="$productCode = 'I1305'">
						    		&CSCMapping_TVCenter;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'VI201'">
						    		&CSCMapping_VoIP2ndLine;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'V8000'">
						    		&CSCMapping_Mobile;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'I1410'">
						    		&CSCMapping_SafetyPackage;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'I1209'">
						    		&CSCMapping_BusinessInternetRegio;
						    		&CSCMapping;
						    	</xsl:when>
						    	<xsl:when test="$productCode = 'VI214'">
						    		&CSCMapping_BusinessVoIP;
						    		&CSCMapping;
						    	</xsl:when>
						    </xsl:choose>
						</xsl:for-each>						
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$activationDateOPM" /> 
							</xsl:element>
						</xsl:element>
						<xsl:if test="$mainAccessServiceCode = 'VI250'">
						    <xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI126</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Ja</xsl:element>
							</xsl:element>
						</xsl:if>	
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReason"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>			

			<xsl:variable name="subsidizedHardwareIndicator">
				<xsl:choose>
					<xsl:when test="request-param-list[@name='parameterList']/request-param-list-item[request-param[@name='parameterName'] = 'subsidizedHardwareIndicator']/request-param[@name='configuredValue'] = ''">
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[request-param[@name='parameterName'] = 'subsidizedHardwareIndicator']/request-param[@name='existingValue']"/>					
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[request-param[@name='parameterName'] = 'subsidizedHardwareIndicator']/request-param[@name='configuredValue']"/>						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="monthlyChargeServiceCode">	
				<xsl:choose>
					<xsl:when test="$productCode = 'I1208'">V0017</xsl:when>
					<xsl:when test="$productCode = 'I1204'">V0017</xsl:when>
					<xsl:when test="$productCode = 'I1203'">V0017</xsl:when>
					<xsl:when test="$productCode = 'I1100'"/>
					<xsl:when test="$productCode = 'VI208'">V0017</xsl:when>
					<xsl:when test="$productCode = 'VI202'">V0017</xsl:when>
					<xsl:when test="$productCode = 'VI203'">V0017</xsl:when>
					<xsl:when test="$productCode = 'V0002'">V0017</xsl:when>
					<xsl:when test="$productCode = 'VI204'"/>
					<xsl:when test="$productCode = 'VI205'">
						<xsl:choose>
							<xsl:when test="request-param[@name='serviceType'] = 'convergedSeat'
								and $subsidizedHardwareIndicator != 'true'">VI050</xsl:when>
							<xsl:when test="request-param[@name='serviceType'] = 'convergedSeat'
								and $subsidizedHardwareIndicator = 'true'">VI051</xsl:when>
							<xsl:when test="request-param[@name='serviceType'] = 'fixedSeat'
								and $subsidizedHardwareIndicator != 'true'">VI052</xsl:when>
							<xsl:when test="request-param[@name='serviceType'] = 'fixedSeat'
								and $subsidizedHardwareIndicator = 'true'">VI053</xsl:when>
							<xsl:when test="request-param[@name='serviceType'] = 'mobileSeat'
								and $subsidizedHardwareIndicator != 'true'">VI054</xsl:when>
							<xsl:when test="request-param[@name='serviceType'] = 'mobileSeat'
								and $subsidizedHardwareIndicator = 'true'">VI055</xsl:when>
						</xsl:choose>						
					</xsl:when>
					<xsl:when test="$productCode = 'VI211'">VI220</xsl:when>
					<xsl:when test="$productCode = 'VI207'"/>
					<xsl:when test="$mainAccessServiceCode = 'I1216'">V0017</xsl:when>
					<xsl:when test="$mainAccessServiceCode = 'I1215'"/>
					<xsl:when test="$mainAccessServiceCode = 'I1207'">V0017</xsl:when>
					<xsl:when test="$productCode = 'I0504'"/>
					<xsl:when test="$productCode = 'I1305'">I1356</xsl:when>
					<xsl:when test="$productCode = 'VI201'">VI220</xsl:when>
					<xsl:when test="$productCode = 'V8000'"/>
					<xsl:when test="$productCode = 'I1410'"/>
					<xsl:when test="$productCode = 'I1209'">V0017</xsl:when>
					<xsl:when test="$productCode = 'VI214'">VI220</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="$monthlyChargeServiceCode != ''">
				<!-- Add Monthly charge Service -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_monthly_charge</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$monthlyChargeServiceCode"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="$reasonRd"/>
						</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
					   <xsl:element name="order_date">
						   <xsl:value-of select="$orderDate"/>
					   </xsl:element>
						<xsl:element name="use_current_pc_version">Y</xsl:element>
						<xsl:element name="service_characteristic_list"/>	
						<xsl:element name="detailed_reason_rd">
							<xsl:value-of select="$detailedReason"/>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>	
			</xsl:if>
			
			<xsl:if test="
				request-param[@name='functionType'] = 'voice' and 
				(request-param[@name='accessType'] = 'isdn' or request-param[@name='accessType'] = 'isdnP2P') and 
				$dslBandwidth != ''">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_V0113</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0113</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="$reasonRd"/>
						</xsl:element> 
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>          
						</xsl:element>
					   <xsl:element name="order_date">
						   <xsl:value-of select="$orderDate"/>
					   </xsl:element>
						<xsl:element name="use_current_pc_version">Y</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
								&CSCMapping_ISDNDSL;
								&CSCMapping;
							</xsl:for-each>						
						</xsl:element>
						<xsl:element name="detailed_reason_rd">
							<xsl:value-of select="$detailedReason"/>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>						
					</xsl:element>
				</xsl:element>
			</xsl:if>
				
		    <xsl:variable name="bundleItemType">	
		        <xsl:choose>
		            <xsl:when test="$productCode = 'I1208'">LTEACCESS</xsl:when>
		            <xsl:when test="$productCode = 'I1204' and $mainAccessServiceCode = 'I1209'">FIBRE_ACC_NGN</xsl:when>
		            <xsl:when test="$productCode = 'I1207' and $mainAccessServiceCode = 'I1207'">FIBRE_ACC_BDSL</xsl:when>
		            <xsl:when test="$productCode = 'I1204'">ACCESS</xsl:when>
		            <xsl:when test="$productCode = 'I1203'">BITACCESS</xsl:when>
		            <xsl:when test="$productCode = 'I1100'">ONLINE_SERVICE</xsl:when>
		            <xsl:when test="$productCode = 'VI208'">LTEVOICE</xsl:when>
		            <xsl:when test="$productCode = 'VI202'">VOICE</xsl:when>
		            <xsl:when test="$productCode = 'VI203'">BITVOIP</xsl:when>
		        	<xsl:when test="$productCode = 'V0002'">VOICE_SERVICE</xsl:when>
		        	<xsl:when test="$productCode = 'VI204'">IPCENTREX_SITE</xsl:when>
		        	<xsl:when test="$productCode = 'VI205'">IPCENTREX_SEAT</xsl:when>
		        	<xsl:when test="$productCode = 'VI211'">SIPTRUNK_SITE</xsl:when>
		        	<xsl:when test="$productCode = 'VI207'">ONB_SERVICE</xsl:when>
		        	<xsl:when test="$productCode = 'I1207'">SDSLACCESS</xsl:when>
		        	<xsl:when test="$productCode = 'I0504'">SDSLACCESS</xsl:when>
		        	<xsl:when test="$productCode = 'I1305'">TV_CENTER</xsl:when>
		        	<xsl:when test="$productCode = 'VI201'">VOIP_SERVICE</xsl:when>		        	
		        	<xsl:when test="$productCode = 'V8000'">MOBILE_SERVICE</xsl:when>		        	
		        	<xsl:when test="$productCode = 'I1410'">SOFTWARE</xsl:when>		        	
		        	<xsl:when test="$productCode = 'I1209'">BIRACCESS</xsl:when>
					<xsl:when test="$productCode = 'VI214'">BUSVOIP_SERVICE</xsl:when>
		        	<xsl:otherwise>unknown</xsl:otherwise>
		        </xsl:choose>
		    </xsl:variable>
		    <!-- add the new  bundle item -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">read_bundle_id</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				    <xsl:element name="bundle_item_type_rd">
				        <xsl:value-of select="$bundleItemType"/>
				    </xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				    <xsl:if test="request-param[@name='futureIndicator'] != ''">
				        <xsl:element name="future_indicator">
				            <xsl:value-of select="request-param[@name='futureIndicator']"/>
				        </xsl:element>
				    </xsl:if>
				</xsl:element>
			</xsl:element>

			<xsl:variable name="additionalBundleItemType">	
				<xsl:choose>
					<xsl:when test="$productCode = 'I1208'">LTEONLINE</xsl:when>
               <xsl:when test="$productCode = 'I1204' and $mainAccessServiceCode = 'I1209'">FIBRE_ONL_NGN</xsl:when>
	            <xsl:when test="$productCode = 'I1207' and $mainAccessServiceCode = 'I1207'">FIBRE_ONL_BDSL</xsl:when>
					<xsl:when test="$productCode = 'I1204'">ONLINE</xsl:when>
					<xsl:when test="$productCode = 'I1203'">BITONLINE</xsl:when>
					<xsl:when test="$productCode = 'I1207'">SDSLONLINE</xsl:when>
					<xsl:when test="$productCode = 'I1209'">BIRONLINE</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="$additionalBundleItemType != ''">
		        <!-- add the new  bundle item of type LTEONLINE -->
		        <xsl:element name="CcmFifModifyBundleItemCmd">
		            <xsl:element name="command_id">modify_bundle_item</xsl:element>
		            <xsl:element name="CcmFifModifyBundleItemInCont">
		                <xsl:element name="bundle_id_ref">
		                    <xsl:element name="command_id">read_bundle_id</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		                <xsl:element name="bundle_item_type_rd">
		                    <xsl:value-of select="$additionalBundleItemType"/>
		                </xsl:element>
		                <xsl:element name="supported_object_id_ref">
		                    <xsl:element name="command_id">add_main_service</xsl:element>
		                    <xsl:element name="field_name">service_subscription_id</xsl:element>
		                </xsl:element>
		                <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
		                <xsl:element name="action_name">ADD</xsl:element>
		                <xsl:if test="request-param[@name='futureIndicator'] != ''">
		                    <xsl:element name="future_indicator">
		                        <xsl:value-of select="request-param[@name='futureIndicator']"/>
		                    </xsl:element>
		                </xsl:if>
		            </xsl:element>
		        </xsl:element>	
		    </xsl:if>

			<xsl:if test="request-param[@name='accessType'] = 'oneNetBusiness'">
				<xsl:choose>
					<xsl:when test="$oneNetId != '' and $siteID != ''">
						<xsl:element name="CcmFifModifyOneNetSiteCmd">
							<xsl:element name="command_id">modify_one_net_site</xsl:element>
							<xsl:element name="CcmFifModifyOneNetSiteInCont">
								<xsl:element name="one_net_id">
									<xsl:value-of select="$oneNetId"/>
								</xsl:element>
								<xsl:element name="site_id">
									<xsl:value-of select="$siteID"/>
								</xsl:element>
				                <xsl:element name="bundle_id_ref">
				                    <xsl:element name="command_id">read_bundle_id</xsl:element>
				                    <xsl:element name="field_name">parameter_value</xsl:element>
				                </xsl:element>
								<xsl:element name="customer_number_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">customer_number</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="CcmFifRaiseErrorCmd">
						    <xsl:element name="command_id">parameter_missing</xsl:element>
						    <xsl:element name="CcmFifRaiseErrorInCont">
						        <xsl:element name="error_text">oneNetID / siteID fehlen für OneNetBusiness-Anlage</xsl:element>
						    </xsl:element>
						</xsl:element>                                      
					</xsl:otherwise>
				</xsl:choose>		
			</xsl:if>

		    <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
				<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<!-- main service -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- monthly charge -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_monthly_charge</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0113 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_V0113</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='oldProductCommitmentNumber']"/>
					</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>   
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='billActivationIndicator'] != ''">
						<xsl:element name="bill_activation_indicator">
							<xsl:value-of select="request-param[@name='billActivationIndicator']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='lanPathFileString']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='oldProductCommitmentNumber']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='scanDate']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='entryDate']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<!-- main service -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- monthly charge -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_monthly_charge</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0113 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_V0113</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>   
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:if test="request-param[@name='processingStatus'] = '' and 
				request-param[@name='releaseCustomerOrder'] = 'Y'">
				<!-- release only for OP scenarios -->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="field_name">customer_order_created</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>				
			
			<!-- save vectoringIndicator for BIT-Internet only -->
			<xsl:if test="request-param[@name='accessType'] = 'ipBitstream' and
						request-param[@name='functionType'] = 'internet' and
						$vectoringIndicator = 'true'">
				<xsl:element name="CcmFifAddCcmParameterMapCmd">
					<xsl:element name="CcmFifAddCcmParameterMapInCont">
						<xsl:element name="supported_object_id_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>						
						</xsl:element>
						<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
						<xsl:element name="param_name_rd">VDSL_VECTORING</xsl:element>
						<xsl:element name="param_value">
							<xsl:value-of select="$vectoringIndicator"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>	
			</xsl:if>			
			
		    <xsl:variable name="contactType">	
		        <xsl:choose>
		            <xsl:when test="$productCode = 'I1208'">CREATE_LTEDSL</xsl:when>
                  <xsl:when test="$productCode = 'I1204' and $mainAccessServiceCode = 'I1209'">ADD_FIBRE_NGN</xsl:when>
	               <xsl:when test="$productCode = 'I1207' and $mainAccessServiceCode = 'I1207'">ADD_FIBRE_BDSL</xsl:when>
		            <xsl:when test="$productCode = 'I1204'">CUSTOMER_ORDER</xsl:when>
		            <xsl:when test="$productCode = 'I1203'">CUSTOMER_ORDER</xsl:when>
		            <xsl:when test="$productCode = 'I1100'">CREATE_ONL</xsl:when>
		            <xsl:when test="$productCode = 'VI208'">CREATE_LTEVOICE</xsl:when>
		            <xsl:when test="$productCode = 'VI202'">VOIP_CONTRACT</xsl:when>
		        	<xsl:when test="$productCode = 'VI203'">VOIP_CONTRACT</xsl:when>
		        	<xsl:when test="$productCode = 'V0002'">CUSTOMER_ORDER</xsl:when>
		        	<xsl:when test="$productCode = 'VI204'">CREATE_IPCSITE</xsl:when>
		        	<xsl:when test="$productCode = 'VI205'">CREATE_IPCSEAT</xsl:when>
		        	<xsl:when test="$productCode = 'VI211'">CREATE_SIPTRUNK</xsl:when>
		        	<xsl:when test="$productCode = 'VI207'">CREATE_ONB</xsl:when>
		        	<xsl:when test="$productCode = 'I1207'">CREATE_SDSL</xsl:when>
		        	<xsl:when test="$productCode = 'I0504'">CREATE_SDSL</xsl:when>
		        	<xsl:when test="$productCode = 'I1305'">ADD_TV_CENTER</xsl:when>
		        	<xsl:when test="$productCode = 'VI201'">VOIP_CONTRACT</xsl:when>
		        	<xsl:when test="$productCode = 'V8000'">CREATE_MOBILE</xsl:when>
		        	<xsl:when test="$productCode = 'I1410'">SECURITY_PACKAGE</xsl:when>
		        	<xsl:when test="$productCode = 'I1209'">ADD_BIR</xsl:when>
					<xsl:when test="$productCode = 'VI214'">CREATE_BVOIP</xsl:when>
		        	<xsl:otherwise>unknown</xsl:otherwise>
		        </xsl:choose>
		    </xsl:variable>
		    <xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">
					    <xsl:value-of select="$contactType"/>
					</xsl:element>
					<xsl:element name="short_description">
					    <xsl:value-of select="$contractName"/>
					    <xsl:text> erstellt</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
							    <xsl:value-of select="$contractName"/>
							    <xsl:text>-Vertrag erstellt.&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>&#xA;Produktnutzung: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">                								
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>)</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			&ContractCreation_OutputParameters;
						
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
