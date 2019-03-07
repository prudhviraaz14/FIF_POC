<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated termination FIF request

  @author schwarje
-->

<!DOCTYPE XSL [
	
<!ENTITY TerminateService_BitDsl SYSTEM "POSTerminateService_BitDSL.xsl">
<!ENTITY TerminateService_BitVoIP SYSTEM "POSTerminateService_BitVoIP.xsl">
<!ENTITY TerminateService_NgnDsl SYSTEM "POSTerminateService_NGNDSL.xsl">
<!ENTITY TerminateService_NgnVoIP SYSTEM "POSTerminateService_NGNVoIP.xsl">
<!ENTITY TerminateService_VoIP SYSTEM "POSTerminateService_VoIP.xsl">
<!ENTITY TerminateService_DSLResale SYSTEM "POSTerminateService_DSLResale.xsl">
<!ENTITY TerminateService_Call SYSTEM "POSTerminateService_Call.xsl">
<!ENTITY TerminateService_Default SYSTEM "POSTerminateService_Default.xsl">
<!ENTITY TerminateService_Simple SYSTEM "POSTerminateService_Simple.xsl">
<!ENTITY TerminateService_Mobile SYSTEM "POSTerminateService_Mobile.xsl">
<!ENTITY TerminateService_Multimedia SYSTEM "POSTerminateService_Multimedia.xsl">
<!ENTITY TerminateService_MOS SYSTEM "POSTerminateService_MOS.xsl">
<!ENTITY TerminateService_PCBackup SYSTEM "POSTerminateService_PCBackup.xsl">
<!ENTITY DecisionMaker_TerminateService SYSTEM "POSDecisionMaker_TerminateService.xsl">
<!ENTITY TerminateService_TVCenter SYSTEM "POSTerminateService_TVCenter.xsl">
<!ENTITY HandleMMAccessHardware SYSTEM "HandleMMAccessHardware.xsl">

]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	exclude-result-prefixes="dateutils">

	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"
		doctype-system="fif_transaction_list.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifTransactionList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="request-params">
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_list_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="transaction_list_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:if test="request-param[@name='clientName'] != ''">      
			<xsl:element name="transaction_list_client_name">
				<xsl:value-of select="request-param[@name='clientName']"/>
			</xsl:element>
		</xsl:if>
		<xsl:element name="intermediate_transaction_list">Y</xsl:element>
		<xsl:element name="transaction_list">
			
			<xsl:variable name="parentCustomerOrderID">
				<xsl:value-of select="request-param[@name='customerOrderID']"/>
			</xsl:variable>
			
			<xsl:variable name="ReasonRd">
				<xsl:value-of select="request-param[@name='reasonRd']"/>
			</xsl:variable> 
			
			<xsl:if test="request-param[@name='terminationType'] = 'Simple'">
				&TerminateService_Simple;
			</xsl:if>
			<xsl:if test="request-param[@name='terminationType'] = 'Complex'">				
				<!-- Generate a FIF date that is one day before the termination date -->
				<xsl:variable name="oneDayBefore"
					select="dateutils:createFIFDateOffset(request-param[@name='terminationDate'], 'DATE', '-1')"/>
				<!-- Convert the termination date to OPM format -->
				<xsl:variable name="terminationDateOPM"
					select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>
		
				<xsl:variable name="OrderVariant">
					<xsl:choose>
						<xsl:when test="request-param[@name='reasonRd'] = 'PROVIDER_CHANGE'">Providerwechsel</xsl:when>	
						<xsl:otherwise>Echte Kündigung</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>	
				
				<!-- Calculate today and one day before the desired date -->
				<xsl:variable name="today" select="dateutils:getCurrentDate()"/>	
				
				<xsl:variable name="NoticePeriodStartDate">
					<xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
				</xsl:variable>          
				
				<xsl:variable name="TerminationReason">
					<xsl:value-of select="request-param[@name='terminationReason']"/>
				</xsl:variable>
				
				<xsl:variable name="TerminationDate">
					<xsl:value-of select="request-param[@name='terminationDate']"/>         
				</xsl:variable>  								
				&DecisionMaker_TerminateService; 
				&TerminateService_Default; 
				&TerminateService_DSLResale;
				&TerminateService_Call; 
				&TerminateService_VoIP; 
				&TerminateService_NgnDsl;
				&TerminateService_NgnVoIP;
				&TerminateService_BitDsl;
				&TerminateService_BitVoIP;
				&TerminateService_Multimedia;
				&TerminateService_Mobile;
				&TerminateService_PCBackup;	
				&TerminateService_MOS;	
				&TerminateService_TVCenter;
				
			</xsl:if>
			<xsl:if test="request-param[@name='terminationType'] != 'Simple' and 
				request-param[@name='terminationType'] != 'Complex'">						
				<xsl:element name="CcmFifCommandList">
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
						<xsl:value-of select="request-param[@name='overrideSystemDate']"/>
					</xsl:element>
					
					<xsl:element name="Command_List">
						<xsl:element name="CcmFifRaiseErrorCmd">
							<xsl:element name="command_id">raise_error</xsl:element>
							<xsl:element name="CcmFifRaiseErrorInCont">
								<xsl:element name="error_text">The termination type has to be either 'Simple' or 'Complex'.</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
