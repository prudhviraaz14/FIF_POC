<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for error handling of the AktualisiereEueKundendatenService

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
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="package_name">
      <xsl:value-of select="request-param[@name='packageName']"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
      

	<!-- IT-k-33212: Dismiss any retry in case of the following error-codes :  CCM1195, CCM1217, CCM1242, CCM1373,CCM2696, CCM2715, CCM2793, CCM4045, CCM4052, CCM4102, CCM6000 -->
    
    <xsl:choose>
		<xsl:when test="request-param[@name='originalRequestResult'] = 'false' and
			(request-param[@name='originalRequestErrorCode'] != 'CFM200'
			or
			request-param[@name='originalRequestErrorCode'] = 'CFM200' and
			not(contains(request-param[@name='originalRequestErrorText'], 'is already completed. Cannot process again')) and	
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=146000')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=141195')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=141217')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=141242')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=141373')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=142696')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=142715')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=142793')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=144052')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=144045')) and
			not(contains(request-param[@name='originalRequestErrorText'], 'errorCode=144102'))) ">

          <!-- get the access number in CCB format from the input fields in SBUS format -->
          <xsl:variable name="accessNumber">
            <xsl:value-of select="request-param[@name='GetExternalIDByPhonenumber;Phonenumber;InternationalAreaCode']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='GetExternalIDByPhonenumber;Phonenumber;Prefix']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='GetExternalIDByPhonenumber;Phonenumber;Number']"/>
          </xsl:variable>

          <xsl:if test="request-param[@name='originalRequestExternalSystemId'] = ''">
            <!-- Find Service Subscription by access number,or service_subscription id  if no bundle was found -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_wholesale_service</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="access_number">
                  <xsl:value-of select="$accessNumber"/>
                </xsl:element>
                <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          
          <xsl:variable name="today"
            select="dateutils:getCurrentDate()"/>
          

		  <!-- IT-k-33212: Delaying any retry from 1 day to 2 days -->
          <xsl:variable name="nextMasterdataUpdate">
                <xsl:value-of select="dateutils:createFIFDateOffset($today, 'DATE', '2')"/>         
          </xsl:variable>
          
          <!-- request the next update -->
          <xsl:element name="CcmFifCreateFifRequestCmd">
            <xsl:element name="command_id">update_master_data</xsl:element> 
            <xsl:element name="CcmFifCreateFifRequestInCont">
              <xsl:element name="action_name">update1Und1MasterData</xsl:element> 
              <xsl:element name="due_date">
                <xsl:value-of select="$nextMasterdataUpdate"/>
              </xsl:element> 
              <xsl:element name="dependent_transaction_id">dummy</xsl:element>
              <xsl:element name="priority">4</xsl:element>
              <xsl:element name="bypass_command">N</xsl:element>
              <xsl:choose>
                <xsl:when test="request-param[@name='originalRequestExternalSystemId'] = ''">
                  <xsl:element name="external_system_id_ref">
                    <xsl:element name="command_id">find_wholesale_service</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>                
                  </xsl:element>					              
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="external_system_id">
                    <xsl:value-of select="request-param[@name='originalRequestExternalSystemId']"/>
                  </xsl:element>                  
                </xsl:otherwise>
              </xsl:choose>
              <xsl:element name="request_param_list">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">customerNumber</xsl:element> 
                  <xsl:choose>
                    <xsl:when test="request-param[@name='originalRequestExternalSystemId'] = ''">
                      <xsl:element name="parameter_value_ref">
                        <xsl:element name="command_id">find_wholesale_service</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                      </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:element name="parameter_value">
                        <xsl:value-of select="request-param[@name='originalRequestExternalSystemId']"/>
                      </xsl:element>                  
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:if test="request-param[@name='originalRequestErrorCode'] != 'CFM200'">
            <!-- Create Contact for Service Addition -->
            <xsl:element name="CcmFifCreateContactCmd">
              <xsl:element name="CcmFifCreateContactInCont">
                <xsl:choose>
                  <xsl:when test="request-param[@name='originalRequestExternalSystemId'] = ''">
                    <xsl:element name="customer_number_ref">
                      <xsl:element name="command_id">find_wholesale_service</xsl:element>
                      <xsl:element name="field_name">customer_number</xsl:element>
                    </xsl:element>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='originalRequestExternalSystemId']"/>
                    </xsl:element>                  
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:element name="contact_type_rd">MASTERDATAUPDATE</xsl:element>
                <xsl:element name="short_description">Stammdatenupd. fehlgeschlagen</xsl:element>
                <xsl:element name="long_description_text">
                  <xsl:text>1und1-Stammdatenupdate, TransactionId: </xsl:text>
                  <xsl:value-of select="request-param[@name='transactionID']"/>
                  <xsl:text>, schlug mit folgender Meldung fehl:</xsl:text>
                  <xsl:text>&#xA;Fehlercode: </xsl:text>
                  <xsl:value-of select="request-param[@name='originalRequestErrorCode']"/>
                  <xsl:text>, Fehlermeldung: </xsl:text>
                  <xsl:value-of select="request-param[@name='originalRequestErrorText']"/>
                  <xsl:text>&#xA;Nächstes Stammdatenupdate: </xsl:text>
                  <xsl:value-of select="$nextMasterdataUpdate"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
        </xsl:when>
        
        <xsl:otherwise>
          <!-- do a dummy command to avoid a parsing error in the CcmFifInterface --> 
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">dummyaction</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">dummyaction</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:otherwise>
        
      </xsl:choose>
    </xsl:element>   
  </xsl:template>
</xsl:stylesheet>
