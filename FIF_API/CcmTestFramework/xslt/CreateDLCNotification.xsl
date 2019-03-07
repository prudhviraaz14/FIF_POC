<!--
	XSLT file for creating a KBA notification for DLC

	@author banania
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:Kba="http://arcor.net/kba/BizTrxInputMessage"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://arcor.net/kba/BizTrxInputMessage">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
	<xsl:template match="/">
		
		<xsl:element name="Kba:ClearingBizTransaction">
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
			<xsl:if
				test="request/request-params/request-param[@name='TYPE'] != 'PROCESS'">
				<xsl:attribute name="trxType">
					<xsl:value-of
						select="request/request-params/request-param[@name='TYPE']"/>
				</xsl:attribute>
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
			<xsl:attribute name="clearingActivityId">
				<xsl:value-of
					select="request/request-params/request-param[@name='CLEARING_ACTIVITY_ID']"/>
			</xsl:attribute>
			<xsl:attribute name="ccbExternalId">
				<xsl:value-of
					select="request/request-params/request-param[@name='CCB_EXTERNAL_ID']"/>
			</xsl:attribute>
			<xsl:attribute name="orderPosition">
				<xsl:value-of
					select="request/request-params/request-param[@name='ORDER_POSITION']"/>
			</xsl:attribute>
			<xsl:attribute name="talCarrierInfoField">
				<xsl:value-of
					select="request/request-params/request-param[@name='TAL_CARRIER_INFO_FIELD']"/>
			</xsl:attribute>
			<xsl:attribute name="onkz">
				<xsl:value-of
					select="request/request-params/request-param[@name='ONKZ']"/>
			</xsl:attribute>
			<xsl:attribute name="asb">
				<xsl:value-of
					select="request/request-params/request-param[@name='ASB']"/>
			</xsl:attribute>			
			<xsl:attribute name="customerSalesSegment">
				<xsl:value-of
					select="request/request-params/request-param[@name='SALES_SEGMENT']"/>
			</xsl:attribute>
			<xsl:attribute name="talCarrierReasonCode">
				<xsl:value-of
					select="request/request-params/request-param[@name='TAL_CARRIER_REASON_CODE']"/>
			</xsl:attribute>
			<xsl:attribute name="clearingReasonCode">
				<xsl:value-of
					select="request/request-params/request-param[@name='CLEARING_REASON_CODE']"/>
			</xsl:attribute>
			<xsl:attribute name="barcode">
				<xsl:value-of
					select="request/request-params/request-param[@name='BAR_CODE']"/>
			</xsl:attribute>
			<xsl:attribute name="product">
				<xsl:value-of
					select="request/request-params/request-param[@name='PRODUCT']"/>
			</xsl:attribute>			
		</xsl:element>
		
						
	</xsl:template>
</xsl:stylesheet>
