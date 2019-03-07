<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
XSLT file for updating permissions

@author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
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
			<xsl:value-of select="request-param[@name='transactionID']" />
		</xsl:element>
		<xsl:element name="client_name">
			<xsl:value-of select="request-param[@name='clientName']" />
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name" />
		</xsl:element>
		<xsl:element name="package_name">
			<xsl:value-of select="request-param[@name='packageName']" />
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']" />
		</xsl:element>
	
		<xsl:element name="Command_List">

         <xsl:choose>
            <xsl:when test="count(request-param-list[@name= 'permissionDetailsList']/request-param-list-item) > 0">
               <xsl:if test="(request-param-list/request-param-list-item[(request-param/@name = 'permissionId' and request-param = 'ADV') and (request-param/@name = 'serviceId' and (request-param = 'GENE'))])
                and
                (request-param-list/request-param-list-item[(request-param/@name = 'permissionId' and request-param = 'ADV') and (request-param/@name = 'serviceId' and not (request-param = 'GENE'))])">
	               <xsl:element name="CcmFifRaiseErrorCmd">
	                  <xsl:element name="command_id">validate_permission_adv_err</xsl:element>
	                  <xsl:element name="CcmFifRaiseErrorInCont">
	                     <xsl:element name="error_text">
	                        <xsl:text>Setting generic and specific permissions for ADV in one request is not allowed.</xsl:text>
	                     </xsl:element>
	                 </xsl:element>
	               </xsl:element>	
               </xsl:if>           
               <xsl:if test="(request-param-list/request-param-list-item[(request-param/@name = 'permissionId' and request-param = 'DEV') and (request-param/@name = 'serviceId' and (request-param = 'GENE'))])
                   and
                   (request-param-list/request-param-list-item[(request-param/@name = 'permissionId' and request-param = 'DEV') and (request-param/@name = 'serviceId' and not (request-param = 'GENE'))])">
	               <xsl:element name="CcmFifRaiseErrorCmd">
	                  <xsl:element name="command_id">validate_permission_adv_err</xsl:element>
	                  <xsl:element name="CcmFifRaiseErrorInCont">
	                     <xsl:element name="error_text">
	                        <xsl:text>Setting generic and specific permissions for DEV in one request is not allowed.</xsl:text>
	                     </xsl:element>
	                 </xsl:element>
	               </xsl:element>	
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:if test="request-param[@name='advGene'] != '' and (request-param[@name='eMail'] != '' or request-param[@name='fax'] != '' or request-param[@name='mail'] != '' or request-param[@name='phone'] != '')">
	               <xsl:element name="CcmFifRaiseErrorCmd">
	                   <xsl:element name="command_id">validate_permission_adv_err</xsl:element>
	                   <xsl:element name="CcmFifRaiseErrorInCont">
	                       <xsl:element name="error_text">
	                           <xsl:text>Setting generic and specific permissions for ADV in one request is not allowed.</xsl:text>
	                       </xsl:element>
	                   </xsl:element>
	               </xsl:element>	
               </xsl:if>
               <xsl:if test="request-param[@name='devGene'] != '' and (request-param[@name='cdev'] != '' or request-param[@name='pdev'] != '' or request-param[@name='geo'] != '' or request-param[@name='wbt'] != '')">
	               <xsl:element name="CcmFifRaiseErrorCmd">
	                   <xsl:element name="command_id">validate_permission_dev_err</xsl:element>
	                   <xsl:element name="CcmFifRaiseErrorInCont">
	                       <xsl:element name="error_text">
	                           <xsl:text>Setting generic and specific permissions for DEV in one request is not allowed.</xsl:text>
	                       </xsl:element>
	                   </xsl:element>
	               </xsl:element>	
               </xsl:if>
            </xsl:otherwise>
         </xsl:choose>
			<xsl:element name="CcmFifUpdatePermissionPreferenceCmd">
				<xsl:element name="command_id">update_permissions</xsl:element>
				<xsl:element name="CcmFifUpdatePermissionPreferenceInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="permission_date">
						<xsl:value-of select="request-param[@name='effectiveTime']"/>
					</xsl:element>
					<xsl:element name="source_system_id">
						<xsl:value-of select="request-param[@name='sourceSystemId']"/>
					</xsl:element>
					<xsl:element name="bew_version">
						<xsl:value-of select="request-param[@name='bewVersion']"/>
					</xsl:element>
					 <!-- added for GDPR long term topic -->
					 <xsl:element name="campaign_id">
						<xsl:value-of select="request-param[@name='campaignID']"/>
					</xsl:element>
					<!-- added for GDPR long term topic -->
					<xsl:element name="VOID">
						<xsl:value-of select="request-param[@name='VOID']"/>
					</xsl:element>
                    <xsl:choose>
                        <xsl:when test="count(request-param-list[@name= 'permissionDetailsList']/request-param-list-item) > 0">
					<xsl:element name="permission_preference_list">
                        <xsl:for-each select="request-param-list[@name= 'permissionDetailsList']/request-param-list-item">
							<xsl:element name="CcmFifPermissionPreferenceCont">
								<xsl:element name="permission_id">                                                                                                                                               
								<xsl:value-of select="request-param[@name='permissionId']"/>
								</xsl:element>
								<xsl:element name="service_id">
								<xsl:value-of select="request-param[@name='serviceId']"/>
								 </xsl:element>
								<xsl:element name="permission_value">
								<xsl:value-of select="request-param[@name='newPermissionValue']"/>
								</xsl:element>
								<!-- added here for GDPR long term topic -->
								<xsl:element name="bew_version">
								<xsl:value-of select="request-param[@name='bewVersion']"/>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="permission_preference_list">
							<xsl:if test="request-param[@name='eMail'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">ADV</xsl:element>
											<xsl:element name="service_id">EMAL</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='eMail']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='fax'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">ADV</xsl:element>
											<xsl:element name="service_id">FAX</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='fax']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='mail'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">ADV</xsl:element>
											<xsl:element name="service_id">MAIL</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='mail']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='phone'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">ADV</xsl:element>
											<xsl:element name="service_id">PHON</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='phone']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='cdev'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">DEV</xsl:element>
											<xsl:element name="service_id">CDEV</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='cdev']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='pdev'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">DEV</xsl:element>
											<xsl:element name="service_id">PDEV</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='pdev']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='geo'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">DEV</xsl:element>
											<xsl:element name="service_id">GEO</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='geo']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<!-- added for GDPR long term topic -->
							<xsl:if test="request-param[@name='wbt'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">DEV</xsl:element>
											<xsl:element name="service_id">WBT</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='wbt']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='advGene'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">ADV</xsl:element>
											<xsl:element name="service_id">GENE</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='advGene']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='devGene'] != ''">
											<xsl:element name="CcmFifPermissionPreferenceCont">
											<xsl:element name="permission_id">DEV</xsl:element>
											<xsl:element name="service_id">GENE</xsl:element>
											<xsl:element name="permission_value">
											<xsl:value-of select="request-param[@name='devGene']"/>
											</xsl:element>
											<xsl:element name="bew_version">
											<xsl:value-of select="request-param[@name='bewVersion']"/>
											</xsl:element>
											</xsl:element>
							</xsl:if>
							</xsl:element>
							</xsl:otherwise>
					</xsl:choose>
					</xsl:element>
				</xsl:element>
				
	 <xsl:variable name="contactText">
        <xsl:text>Änderung der Marketingeinwilligungsdaten über: </xsl:text>
        <xsl:value-of select="request-param[@name='clientName']"/>
        <xsl:text> geändert.&#xA;TransactionID: </xsl:text>
        <xsl:value-of select="request-param[@name='transactionID']"/>
      </xsl:variable>
		
		            
      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select= "request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">CUSTOMER</xsl:element>
          <xsl:element name="short_description">Marketingeinwilligungsänderung</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:value-of select="$contactText"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

	  
	  
	</xsl:element>	
	</xsl:template>
</xsl:stylesheet>
