<!--
	XSLT file for creating a KBA notification

	@author goethalo
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:Kba="http://arcor.net/kba/BizTrxInputMessage"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://arcor.net/kba/BizTrxInputMessage">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
	<xsl:template match="/">
		<xsl:if test="request/request-params/request-param[@name='CATEGORY'] != 'adjustmentNotification'">
			<xsl:element name="Kba:BizTransaction">
				<!-- Get today's date in KBA format -->
				<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
				<xsl:variable name="todayKBA"
					select="dateutils:createKBADate($today)"/>

				<xsl:variable name="DesiredDate" select="request/request-params/request-param[@name='DESIRED_DATE']"/>
				<xsl:variable name="DesiredDateKBA"
					select="dateutils:createKBADate($DesiredDate)"/>

				<xsl:attribute name="xsi:schemaLocation">http://arcor.net/kba/BizTrxInputMessage BizTrxInputMessage.xsd</xsl:attribute>
				<xsl:attribute name="category">
					<xsl:value-of
						select="request/request-params/request-param[@name='CATEGORY']"/>
				</xsl:attribute>
				<xsl:attribute name="customerNumber">
					<xsl:value-of
						select="request/request-params/request-param[@name='CUSTOMER_NUMBER']"/>
				</xsl:attribute>
				<xsl:attribute name="inputChannel">
					<xsl:value-of
						select="request/request-params/request-param[@name='INPUT_CHANNEL']"/>
				</xsl:attribute>
				<xsl:attribute name="customerNumber">
					<xsl:value-of
						select="request/request-params/request-param[@name='CUSTOMER_NUMBER']"/>
				</xsl:attribute>
				<xsl:if
					test="request/request-params/request-param[@name='TYPE'] = 'CONTACT'">
					<xsl:attribute name="trxType">contact</xsl:attribute>
				</xsl:if>
				<xsl:if
					test="request/request-params/request-param[@name='TYPE'] = 'PROCESS'">
					<xsl:attribute name="trxType">process</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="user">
					<xsl:value-of
						select="request/request-params/request-param[@name='USER_NAME']"/>
				</xsl:attribute>
				<xsl:attribute name="workdate">
					<xsl:value-of select="$todayKBA"/>
				</xsl:attribute>
				<xsl:if
					test="$DesiredDateKBA != ''">
					<xsl:attribute name="desiredDate">
					  <xsl:value-of select="$DesiredDateKBA"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if
					test="request/request-params/request-param[@name='BAR_CODE'] != ''">
					<xsl:attribute name="orderId">
						<xsl:value-of select="request/request-params/request-param[@name='BAR_CODE']"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if
					test="request/request-params/request-param[@name='ORDER_POSITION'] != ''">
					<xsl:attribute name="orderPosition">
						<xsl:value-of select="request/request-params/request-param[@name='ORDER_POSITION']"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="request/request-params/request-param[@name='TEXT'] != ''">
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
					<xsl:value-of
						select="request/request-params/request-param[@name='TEXT']"
						disable-output-escaping="yes"/>
					<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
				</xsl:if>
				<xsl:if
					test="request/request-params/request-param[@name='CONTRACT_NUMBER'] != '' or
					request/request-params/request-param[@name='LINE_KEY_NUMBER'] != '' or
					request/request-params/request-param[@name='OLD_ACTIVATION_DATE'] != '' or
					request/request-params/request-param[@name='NEW_ACTIVATION_DATE'] != '' or
					request/request-params/request-param[@name='email'] != '' or
					request/request-params/request-param[@name='bounceReason'] != '' or
					request/request-params/request-param[@name='resultDate'] != ''">
					<xsl:element name="History">
						<xsl:attribute name="Action">
							<xsl:choose>
								<xsl:when test="request/request-params/request-param[@name='ACTION'] != ''">
									<xsl:value-of select="request/request-params/request-param[@name='ACTION']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="request/request-params/request-param[@name='CATEGORY']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="request/request-params/request-param[@name='CONTRACT_NUMBER'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">contractNumber</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='CONTRACT_NUMBER']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request/request-params/request-param[@name='LINE_KEY_NUMBER'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">lineKeyNumber</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='LINE_KEY_NUMBER']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request/request-params/request-param[@name='OLD_ACTIVATION_DATE'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">oldActivationDate</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='OLD_ACTIVATION_DATE']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request/request-params/request-param[@name='NEW_ACTIVATION_DATE'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">newActivationDate</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='NEW_ACTIVATION_DATE']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request/request-params/request-param[@name='email'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">email</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='email']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request/request-params/request-param[@name='bounceReason'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">bounceReason</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='bounceReason']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request/request-params/request-param[@name='resultDate'] != ''">
							<xsl:element name="Value">
								<xsl:attribute name="key">resultDate</xsl:attribute>
								<xsl:attribute name="value">
									<xsl:value-of select="request/request-params/request-param[@name='resultDate']"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:if>
		</xsl:element>
		</xsl:if>
		<xsl:if test="request/request-params/request-param[@name='CATEGORY'] = 'adjustmentNotification'">
			<xsl:element name="Kba:DirectedBizTransaction">
				<!-- Get today's date in KBA format -->
				<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
				<xsl:variable name="todayKBA"
					select="dateutils:createKBADate($today)"/>

				<xsl:attribute name="xsi:schemaLocation">http://arcor.net/kba/BizTrxInputMessage BizTrxInputMessage.xsd</xsl:attribute>
				<xsl:attribute name="category">
					<xsl:value-of
						select="request/request-params/request-param[@name='CATEGORY']"/>
				</xsl:attribute>
				<xsl:attribute name="customerNumber">
					<xsl:value-of
						select="request/request-params/request-param[@name='CUSTOMER_NUMBER']"/>
				</xsl:attribute>
				<xsl:attribute name="inputChannel">
					<xsl:value-of
						select="request/request-params/request-param[@name='INPUT_CHANNEL']"/>
				</xsl:attribute>
				<xsl:attribute name="customerNumber">
					<xsl:value-of
						select="request/request-params/request-param[@name='CUSTOMER_NUMBER']"/>
				</xsl:attribute>
				<xsl:if
					test="request/request-params/request-param[@name='TYPE'] = 'CONTACT'">
					<xsl:attribute name="trxType">contact</xsl:attribute>
				</xsl:if>
				<xsl:if
					test="request/request-params/request-param[@name='TYPE'] = 'PROCESS'">
					<xsl:attribute name="trxType">process</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="receiverHint">
					<xsl:value-of
						select="request/request-params/request-param[@name='RECEIVER_HINT']"/>
				</xsl:attribute>
				<xsl:attribute name="user">
					<xsl:value-of
						select="request/request-params/request-param[@name='USER_NAME']"/>
				</xsl:attribute>
				<xsl:attribute name="workdate">
					<xsl:value-of select="$todayKBA"/>
				</xsl:attribute>
				<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<xsl:value-of
					select="request/request-params/request-param[@name='TEXT']"
					disable-output-escaping="yes"/>
				<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
			</xsl:element>
		</xsl:if>

	</xsl:template>
</xsl:stylesheet>
