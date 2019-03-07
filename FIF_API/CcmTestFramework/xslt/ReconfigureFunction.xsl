<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for for reconfiguring service subscriptions
  @author schwarje
-->

<!DOCTYPE XSL [

<!ENTITY CSCMapping SYSTEM "CSCMapping.xsl">
<!ENTITY CSCMapping_IPCentrexSeat SYSTEM "CSCMapping_IPCentrexSeat.xsl">
<!ENTITY CSCMapping_IPCentrexSite SYSTEM "CSCMapping_IPCentrexSite.xsl">
<!ENTITY CSCMapping_BusinessDSL SYSTEM "CSCMapping_BusinessDSL.xsl">
<!ENTITY CSCMapping_ISDN SYSTEM "CSCMapping_ISDN.xsl">
<!ENTITY CSCMapping_ISDNDSL SYSTEM "CSCMapping_ISDNDSL.xsl">
<!ENTITY CSCMapping_FixedIPAddress SYSTEM "CSCMapping_FixedIPAddress.xsl">
<!ENTITY CSCMapping_AddressCreation SYSTEM "CSCMapping_AddressCreation.xsl">
<!ENTITY CSCMapping_LTEInternet SYSTEM "CSCMapping_LTEInternet.xsl">
<!ENTITY CSCMapping_LTEVoice SYSTEM "CSCMapping_LTEVoice.xsl">
<!ENTITY CSCMapping_TVCenter SYSTEM "CSCMapping_TVCenter.xsl">
<!ENTITY CSCMapping_BitDSL SYSTEM "CSCMapping_BitDSL.xsl">
<!ENTITY CSCMapping_BitVoIP SYSTEM "CSCMapping_BitVoIP.xsl">
<!ENTITY CSCMapping_NGNDSL SYSTEM "CSCMapping_NGNDSL.xsl">
<!ENTITY CSCMapping_NGNVoIP SYSTEM "CSCMapping_NGNVoIP.xsl">
<!ENTITY CSCMapping_VoIP2ndLine SYSTEM "CSCMapping_VoIP2ndLine.xsl">
<!ENTITY CSCMapping_Hardware SYSTEM "CSCMapping_Hardware.xsl">
<!ENTITY CSCMapping_HardwareBundle SYSTEM "CSCMapping_HardwareBundle.xsl">
<!ENTITY CSCMapping_IPCentrexBandwidth SYSTEM "CSCMapping_IPCentrexBandwidth.xsl">
<!ENTITY CSCMapping_InstantAccess SYSTEM "CSCMapping_InstantAccess.xsl">
<!ENTITY CSCMapping_SafetyPackage SYSTEM "CSCMapping_SafetyPackage.xsl">
<!ENTITY CSCMapping_SIPTrunk SYSTEM "CSCMapping_SIPTrunk.xsl">
<!ENTITY CSCMapping_OneNetBusiness SYSTEM "CSCMapping_OneNetBusiness.xsl">
<!ENTITY CSCMapping_Online SYSTEM "CSCMapping_Online.xsl">
<!ENTITY CSCMapping_DirectoryEntry SYSTEM "CSCMapping_DirectoryEntry.xsl">
<!ENTITY CSCMapping_ExtraNumbers SYSTEM "CSCMapping_ExtraNumbers.xsl">
<!ENTITY CSCMapping_ISDNP2P SYSTEM "CSCMapping_ISDNP2P.xsl">
<!ENTITY CSCMapping_ISDNP2PExtraLine SYSTEM "CSCMapping_ISDNP2PExtraLine.xsl">
<!ENTITY CSCMapping_BusinessInternetRegio SYSTEM "CSCMapping_BusinessInternetRegio.xsl">
<!ENTITY CSCMapping_MobileUsage SYSTEM "CSCMapping_MobileUsage.xsl">
<!ENTITY CSCMapping_BusinessVoIP SYSTEM "CSCMapping_BusinessVoIP.xsl">
<!ENTITY CSCMapping_ReferenceOrder SYSTEM "CSCMapping_ReferenceOrder.xsl">
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

    <!-- variable for indicating that this is a reconfiguration -->
    <xsl:variable name="isReconfiguration">Y</xsl:variable>

    <!-- Calculate today and one day before the desired date -->
    <xsl:variable name="today" 
      select="dateutils:getCurrentDate()"/>
    <xsl:variable name="tomorrow"
      select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
    <xsl:element name="Command_List">

      <xsl:variable name="productCode">
        <xsl:value-of select="request-param[@name='productCode']"/>
      </xsl:variable>

      <xsl:variable name="serviceCode">
        <xsl:value-of select="request-param[@name='serviceCode']"/>
      </xsl:variable>
      
      <xsl:variable name="accessType">
        <xsl:value-of select="request-param[@name='accessType']"/>
      </xsl:variable>
      <xsl:variable name="accessConfigurationType">
        <xsl:value-of select="request-param[@name='accessConfigurationType']"/>
      </xsl:variable>
      
      <xsl:variable name="functionType">
        <xsl:value-of select="request-param[@name='functionType']"/>
      </xsl:variable>
      <xsl:variable name="serviceType">
        <xsl:value-of select="request-param[@name='serviceType']"/>
      </xsl:variable>
      
      <xsl:variable name="isServiceCodeHardware">
        <xsl:if test="request-param[@name='serviceCode'] = 'I1049' or
          request-param[@name='serviceCode'] = 'I1223' or
          request-param[@name='serviceCode'] = 'I128K' or
          request-param[@name='serviceCode'] = 'I1291' or
          request-param[@name='serviceCode'] = 'I1293' or
          request-param[@name='serviceCode'] = 'I1294' or
          request-param[@name='serviceCode'] = 'I1295' or
          request-param[@name='serviceCode'] = 'I1350' or
          request-param[@name='serviceCode'] = 'I1359' or
          request-param[@name='serviceCode'] = 'I135A' or
          request-param[@name='serviceCode'] = 'V0048' or
          request-param[@name='serviceCode'] = 'V0107' or
          request-param[@name='serviceCode'] = 'V0108' or
          request-param[@name='serviceCode'] = 'V0109' or
          request-param[@name='serviceCode'] = 'V0110' or
          request-param[@name='serviceCode'] = 'V0114' or
          request-param[@name='serviceCode'] = 'V011A' or
          request-param[@name='serviceCode'] = 'V011C' or
          request-param[@name='serviceCode'] = 'V0328' or
          request-param[@name='serviceCode'] = 'V0330' or
          request-param[@name='serviceCode'] = 'V0335' or
          request-param[@name='serviceCode'] = 'VI057' or
          request-param[@name='serviceCode'] = 'VI041'
          ">
          <xsl:text>Y</xsl:text>
        </xsl:if>
      </xsl:variable>

      <!-- relevant to distinguish between SIP-Trunk S0 and S2M -->
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

      <!-- indicates, what the Business-DSL function belongs to (only for businessDSL-internet) -->
      <xsl:variable name="technology">
      	<xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
        	request-param[@name='parameterName'] = 'technology']/request-param[@name='configuredValue']" />						
      </xsl:variable>

      <xsl:variable name="reason">
        <xsl:value-of select="request-param[@name='reason']"/>
      </xsl:variable>

      <xsl:variable name="childServiceCode">
        <xsl:value-of select="request-param[@name='childServiceCode']"/>
      </xsl:variable>

      <xsl:variable name="desiredDate">
        <xsl:choose>
          <xsl:when test ="request-param[@name='desiredDate'] = '' or
            request-param[@name='desiredDate'] = 'today' or
            request-param[@name='processingStatus'] = 'completedOPM'">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:when test ="dateutils:compareString(request-param[@name='desiredDate'], $today) = '-1'">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:when test="request-param[@name='desiredDate'] = 'tomorrow'">
            <xsl:value-of select="$tomorrow"/>
          </xsl:when>          
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="activationDateOPM">
        <xsl:choose>
          <xsl:when test="request-param[@name='activationDate'] != ''">
            <xsl:value-of select="dateutils:createOPMDate(request-param[@name='activationDate'])" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="dateutils:createOPMDate($desiredDate)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="scheduleType">
        <xsl:choose>
          <xsl:when test="$desiredDate = $today">ASAP</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='scheduleType']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="request-param[@name='skipReconfiguration'] != 'Y'">
  
        <xsl:choose>
          <xsl:when test="$functionType = 'directoryEntry'">
            <!-- Get bundle id -->     
            <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_bundle_id</xsl:element>
              <xsl:element name="CcmFifReadExternalNotificationInCont">
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="parameter_name">
                  <xsl:text>BUNDLE_ID</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- check if the SS provided is still active -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                </xsl:element>
                <xsl:element name="no_stp_error">N</xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">ORDERED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- if the SS provided is no longer active, look for the main voice service in the bundle -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_main_access_stp</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="no_stp_error">Y</xsl:element>
                <xsl:element name="bundle_id_ref">
                  <xsl:element name="command_id">read_bundle_id</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0003</xsl:element>								
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0010</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0011</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0012</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI002</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI003</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI006</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI009</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI010</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI018</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI019</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI020</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>							
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI021</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>							
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">N</xsl:element>						
              </xsl:element>
            </xsl:element>
            
            <!-- after finding the main voice service look for an existing directory entry below it -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="parent_service_subs_ref">
                  <xsl:element name="command_id">find_main_access_stp</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="no_stp_error">Y</xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0100</xsl:element>								
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0327</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">N</xsl:element>						
              </xsl:element>
            </xsl:element>
    
            <!-- get service by STP found before -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">
                <xsl:choose>
                  <xsl:when test="request-param[@name='childServiceCode'] != ''">find_parent_service</xsl:when>
                  <xsl:otherwise>find_main_service</xsl:otherwise>
                </xsl:choose>              
              </xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_ticket_position_id_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">service_ticket_position_id</xsl:element>
                </xsl:element>
                <xsl:element name="no_service_error">Y</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>						
              </xsl:element>
            </xsl:element>          
          </xsl:when>

          <xsl:when test="$functionType = 'hardware'">
            <!-- Get bundle id -->     
            <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_bundle_id</xsl:element>
              <xsl:element name="CcmFifReadExternalNotificationInCont">
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="parameter_name">
                  <xsl:text>BUNDLE_ID</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- check if the SS provided is still active -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                </xsl:element>
                <xsl:element name="no_stp_error">N</xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">5</xsl:element>
                    <xsl:element name="service_subscription_state">PURCHASED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">5</xsl:element>
                    <xsl:element name="service_subscription_state">ORDERED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">6</xsl:element>
                    <xsl:element name="service_subscription_state">RENTED_LEASED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">6</xsl:element>
                    <xsl:element name="service_subscription_state">ORDERED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- if the SS provided is no longer active, look for the main access service in the bundle -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_main_access_stp</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="no_stp_error">Y</xsl:element>
                <xsl:element name="bundle_id_ref">
                  <xsl:element name="command_id">read_bundle_id</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0003</xsl:element>								
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0010</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0011</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">V0012</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">I1210</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">I1213</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">I1290</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI010</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>							
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI020</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>							
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_code">VI021</xsl:element>
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
                  </xsl:element>							
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">N</xsl:element>						
              </xsl:element>
            </xsl:element>
            
            <!-- after finding the main voice service look for the hardware by articleNumber -->
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="parent_service_subs_ref">
                  <xsl:element name="command_id">find_main_access_stp</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="no_stp_error">Y</xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_char_code">V0112</xsl:element>
                    <xsl:element name="configured_value_string">
                      <xsl:choose>
                        <xsl:when test="count(request-param-list[@name='parameterList']/request-param-list-item[
                          request-param[@name='parameterName'] = 'articleNumber']
                          /request-param[@name='existingValue']) > 0">
                          <xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
                            request-param[@name='parameterName'] = 'articleNumber']
                            /request-param[@name='existingValue']" />                          
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
                            request-param[@name='parameterName'] = 'articleNumber']
                            /request-param[@name='configuredValue']" />                                                    
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:element>
                    <xsl:element name="service_subscription_state">RENTED_LEASED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="service_char_code">V0112</xsl:element>
                    <xsl:element name="configured_value_string">
                      <xsl:choose>
                        <xsl:when test="count(request-param-list[@name='parameterList']/request-param-list-item[
                          request-param[@name='parameterName'] = 'articleNumber']
                          /request-param[@name='existingValue']) > 0">
                          <xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
                            request-param[@name='parameterName'] = 'articleNumber']
                            /request-param[@name='existingValue']" />                          
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="request-param-list[@name='parameterList']/request-param-list-item[
                            request-param[@name='parameterName'] = 'articleNumber']
                            /request-param[@name='configuredValue']" />                                                    
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:element>
                    <xsl:element name="service_subscription_state">PURCHASED</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">N</xsl:element>						
              </xsl:element>
            </xsl:element>
            
            <!-- get service by STP found before -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">
                <xsl:choose>
                  <xsl:when test="request-param[@name='childServiceCode'] != ''">find_parent_service</xsl:when>
                  <xsl:otherwise>find_main_service</xsl:otherwise>
                </xsl:choose>              
              </xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_ticket_position_id_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">service_ticket_position_id</xsl:element>
                </xsl:element>
                <xsl:element name="no_service_error">Y</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_to_reconfigure</xsl:element>
                  <xsl:element name="field_name">stp_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>						
              </xsl:element>
            </xsl:element>          
          </xsl:when>
          
          <xsl:otherwise>
            <!-- Find Service Subscription by service_subscription id  -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">
                <xsl:choose>
                  <xsl:when test="request-param[@name='childServiceCode'] != ''">find_parent_service</xsl:when>
                  <xsl:otherwise>find_main_service</xsl:otherwise>
                </xsl:choose>
              </xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>            
          </xsl:otherwise>          
        </xsl:choose>
  
  
        <xsl:if test="request-param[@name='childServiceCode'] != ''">
          <!-- Find Child Service to reconfigure -->
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="product_subscription_id_ref">
                <xsl:element name="command_id">find_parent_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="request-param[@name='childServiceCode']"/>
              </xsl:element>
              <xsl:if test="request-param[@name='alternativeChildServiceCode'] != ''">
                <xsl:element name="no_service_error">N</xsl:element>
              </xsl:if>
            </xsl:element>
          </xsl:element>
          
          <xsl:if test="request-param[@name='alternativeChildServiceCode'] != ''">
            <!-- Find alternative Child Service to reconfigure, if first try didn't work -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="product_subscription_id_ref">
                  <xsl:element name="command_id">find_parent_service</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_code">
                  <xsl:value-of select="request-param[@name='alternativeChildServiceCode']"/>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_main_service</xsl:element>
                  <xsl:element name="field_name">service_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">N</xsl:element>                
              </xsl:element>
            </xsl:element>            
          </xsl:if>            
        </xsl:if>
  
        <!-- Lock product subscription  -->
        <xsl:element name="CcmFifLockObjectCmd">
          <xsl:element name="CcmFifLockObjectInCont">
            <xsl:element name="object_id_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="object_type">PROD_SUBS</xsl:element>
          </xsl:element>
        </xsl:element>
  
        <!-- Get Entity Information -->
        <xsl:element name="CcmFifGetEntityCmd">
          <xsl:element name="command_id">get_entity</xsl:element>
          <xsl:element name="CcmFifGetEntityInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
  
        <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
          <xsl:choose>
            <xsl:when test="$accessType = 'ipCentrex' and $functionType = 'voice'">
              &CSCMapping_IPCentrexSite;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'ipCentrex' and $functionType = 'seat'">
              &CSCMapping_IPCentrexSeat;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'businessDSL' and $functionType = 'internet' and $serviceType = 'fibreInternet'">
              &CSCMapping_FibreInternet;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'businessDSL' and $functionType = 'internet'">
              &CSCMapping_BusinessDSL;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'sipTrunk' and $functionType = 'voice'">
              &CSCMapping_SIPTrunk;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'oneNetBusiness' and $functionType = 'voice'">
              &CSCMapping_OneNetBusiness;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdn' and $functionType = 'voice' and $childServiceCode = 'V0113'">
              &CSCMapping_ISDNDSL;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdn' and $functionType = 'voice'">
              &CSCMapping_ISDN;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdn' and $functionType = 'internet'">
              &CSCMapping_Online;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'voice' and $childServiceCode = 'V0113'">
              &CSCMapping_ISDNDSL;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'voice'">
              &CSCMapping_ISDNP2P;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'extraLine'">
              &CSCMapping_ISDNP2PExtraLine;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'internet'">
              &CSCMapping_Online;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'lte' and $functionType = 'voice'">
              &CSCMapping_LTEVoice;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'lte' and $functionType = 'internet'">
              &CSCMapping_LTEInternet;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'ipBitstream' and $functionType = 'voice'">
              &CSCMapping_BitVoIP;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'ipBitstream' and $functionType = 'internet' and $accessConfigurationType != 'businessIpBitstream'">
              &CSCMapping_BitDSL;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'ngn' and $functionType = 'voice'">
              &CSCMapping_NGNVoIP;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'ngn' and $functionType = 'internet' and $serviceType = 'fibreInternet'">
              &CSCMapping_FibreInternet;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'ngn' and $functionType = 'internet'">
              &CSCMapping_NGNDSL;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$accessType = 'sip' and $functionType = 'voice'">
              &CSCMapping_VoIP2ndLine;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <!-- For Business-Internet-Regio -->
           <xsl:when test="$accessType = 'ipBitstream' and $functionType = 'internet' and $accessConfigurationType = 'businessIpBitstream'">
            	&CSCMapping_BusinessInternetRegio;
             	&CSCMapping_AddressCreation;
           	</xsl:when>
            <xsl:when test="$accessType = 'businessVoip'">
				  &CSCMapping_BusinessVoIP;
				  &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$functionType = 'hardware'">
              &CSCMapping_Hardware;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$functionType = 'directoryEntry'">
              &CSCMapping_DirectoryEntry;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$functionType = 'extraNumbers'">
              &CSCMapping_ExtraNumbers;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$functionType = 'tvCenter'">
              &CSCMapping_TVCenter;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$functionType = 'safetyPackage'">
              &CSCMapping_SafetyPackage;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$serviceCode = '' and $productCode = 'VI201'">
              &CSCMapping_VoIP2ndLine;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$serviceCode = '' and $productCode = 'I1410'">
              &CSCMapping_SafetyPackage;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$serviceCode != '' and $isServiceCodeHardware = 'Y'">
              &CSCMapping_Hardware;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$serviceCode = 'V8042'">
              &CSCMapping_InstantAccess;
              &CSCMapping_AddressCreation;
            </xsl:when>
            <xsl:when test="$functionType = 'mobileUsage'">
              &CSCMapping_MobileUsage;
              &CSCMapping_AddressCreation;
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
        
        <xsl:if test="request-param[@name='useExistingServiceTicketPosition'] != 'Y'">
          <!-- find an open customer order for the main service -->
          <xsl:element name="CcmFifFindServiceTicketPositionCmd">
            <xsl:element name="command_id">find_open_stp</xsl:element>
            <xsl:element name="CcmFifFindServiceTicketPositionInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>         
              <xsl:element name="no_stp_error">N</xsl:element>
              <xsl:element name="find_stp_parameters">            
                <xsl:element name="CcmFifFindStpParameterCont">
                  <xsl:element name="usage_mode_value_rd">2</xsl:element>
                  <xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifFindStpParameterCont">
                  <xsl:element name="usage_mode_value_rd">2</xsl:element>
                  <xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        
          <!-- cancel the ASSIGNED or UNASSIGNED STP -->
          <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
            <xsl:element name="command_id">cancel_open_stp</xsl:element>
            <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
              <xsl:element name="service_ticket_position_id_ref">
                <xsl:element name="command_id">find_open_stp</xsl:element>
                <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
              </xsl:element>
              <xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_open_stp</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>          	
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>            
            </xsl:element>
          </xsl:element>          
        </xsl:if>
        
        <xsl:if test="request-param[@name='useExistingServiceTicketPosition'] = 'Y'">
          <!-- find an open customer order for the main service -->
          <xsl:element name="CcmFifFindServiceTicketPositionCmd">
            <xsl:element name="command_id">find_open_stp</xsl:element>
            <xsl:element name="CcmFifFindServiceTicketPositionInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>         
              <xsl:element name="no_stp_error">N</xsl:element>
              <xsl:element name="find_stp_parameters">            
                <xsl:element name="CcmFifFindStpParameterCont">
                  <xsl:element name="usage_mode_value_rd">2</xsl:element>
                  <xsl:element name="customer_order_state">DEFINED</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>			
        
        <!-- only reconfigure SS in allowed status -->
		  <xsl:element name="CcmFifValidateValueCmd">
			  <xsl:element name="command_id">validate_product_code_1</xsl:element>
			  <xsl:element name="CcmFifValidateValueInCont">
				  <xsl:element name="value_ref">
					  <xsl:element name="command_id">find_main_service</xsl:element>
					  <xsl:element name="field_name">state_rd</xsl:element>
				  </xsl:element>
				  <xsl:element name="object_type">V0100 service subscription</xsl:element>
				  <xsl:element name="value_type">state rd</xsl:element>
				  <xsl:element name="allowed_values">
					  <xsl:element name="CcmFifPassingValueCont">
						  <xsl:element name="value">ORDERED</xsl:element>
					  </xsl:element>						
					  <xsl:element name="CcmFifPassingValueCont">
						  <xsl:element name="value">SUBSCRIBED</xsl:element>
					  </xsl:element>						
					  <xsl:element name="CcmFifPassingValueCont">
						  <xsl:element name="value">SUSPENDED</xsl:element>
					  </xsl:element>						
				  </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_main_service</xsl:element>
                <xsl:element name="field_name">service_code</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">V0100</xsl:element>
			  </xsl:element>
		  </xsl:element>			

        <!-- Remove DEACT record for purchased services if any -->
        <xsl:element name="CcmFifRemoveDeactCSCsForPurchasedServiceCmd">
          <xsl:element name="command_id">remove_deact_cscs_1</xsl:element>
          <xsl:element name="CcmFifRemoveDeactCSCsForPurchasedServiceInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Reconfigure ASAP if no customer order found -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_main_service</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='useExistingServiceTicketPosition'] = 'Y'">
              <xsl:element name="service_ticket_position_id_ref">
                <xsl:element name="command_id">find_open_stp</xsl:element>
                <xsl:element name="field_name">service_ticket_position_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="desired_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">
              <xsl:value-of select="$scheduleType"/>
            </xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$reason"/>
            </xsl:element>
            <xsl:element name="service_characteristic_list">
              <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                <xsl:if test="request-param[@name='action'] = 'remove'
                  or request-param[@name='existingValue'] != request-param[@name='configuredValue']
                  and request-param[@name='configuredValue'] != ''
                  or request-param[@name='existingFloor'] != request-param[@name='configuredFloor']
                  and request-param[@name='configuredFloor'] != ''
                  or request-param[@name='existingRoomNumber'] != request-param[@name='configuredRoomNumber']
                  and request-param[@name='configuredRoomNumber'] != ''
                  or request-param[@name='existingJackLocation'] != request-param[@name='configuredJackLocation']
                  and request-param[@name='configuredJackLocation'] != ''
                  or request-param[@name='existingDeskNumber'] != request-param[@name='configuredDeskNumber']
                  and request-param[@name='configuredDeskNumber'] != ''
                  or request-param[@name='existingAdditionalLocationInfo'] != request-param[@name='configuredAdditionalLocationInfo']
                  and request-param[@name='configuredAdditionalLocationInfo'] != ''
                  or request-param[@name='existingCountryCode'] != request-param[@name='configuredCountryCode']
                  and request-param[@name='configuredCountryCode'] != ''
                  or request-param[@name='existingAreaCode'] != request-param[@name='configuredAreaCode']
                  and request-param[@name='configuredAreaCode'] != ''
                  or request-param[@name='existingLocalNumber'] != request-param[@name='configuredLocalNumber']
                  and request-param[@name='configuredLocalNumber'] != ''
                  or request-param[@name='existingStartNumber'] != request-param[@name='configuredStartNumber']
                  and request-param[@name='configuredStartNumber'] != ''
                  or request-param[@name='existingEndNumber'] != request-param[@name='configuredEndNumber']
                  and request-param[@name='configuredEndNumber'] != ''
                  or request-param[@name='existingStreet'] != request-param[@name='configuredStreet']
                  and request-param[@name='configuredStreet'] != ''
                  or request-param[@name='existingStreetNumber'] != request-param[@name='configuredStreetNumber']
                  and request-param[@name='configuredStreetNumber'] != ''
                  or request-param[@name='existingStreetNumberSuffix'] != request-param[@name='configuredStreetNumberSuffix']
                  and request-param[@name='configuredStreetNumberSuffix'] != ''
                  or request-param[@name='existingPostalCode'] != request-param[@name='configuredPostalCode']
                  and request-param[@name='configuredPostalCode'] != ''
                  or request-param[@name='existingCity'] != request-param[@name='configuredCity']
                  and request-param[@name='configuredCity'] != ''
                  or request-param[@name='existingCitySuffix'] != request-param[@name='configuredCitySuffix']
                  and request-param[@name='configuredCitySuffix'] != ''
                  or request-param[@name='existingCountry'] != request-param[@name='configuredCountry']
                  and request-param[@name='configuredCountry'] != ''
                  or request-param[@name='existingAdditionalAddressDescription'] != request-param[@name='configuredAdditionalAddressDescription']
                  and request-param[@name='configuredAdditionalAddressDescription'] != ''
                  or request-param[@name='existingSalutation'] != request-param[@name='configuredSalutation']
                  and request-param[@name='configuredSalutation'] != ''
                  or request-param[@name='existingFirstName'] != request-param[@name='configuredFirstName']
                  and request-param[@name='configuredFirstName'] != ''
                  or request-param[@name='existingName'] != request-param[@name='configuredName']
                  and request-param[@name='configuredName'] != ''">

		          <xsl:choose>
		            <xsl:when test="$accessType = 'ipCentrex' and $functionType = 'voice'">
		              &CSCMapping_IPCentrexSite;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'ipCentrex' and $functionType = 'seat'">
		              &CSCMapping_IPCentrexSeat;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$serviceCode = '' and ($childServiceCode = 'I1222' or $childServiceCode = 'I104B')">
                      &CSCMapping_FixedIPAddress;
                      &CSCMapping;
                    </xsl:when>
                  <xsl:when test="$accessType = 'businessDSL' and $functionType = 'internet' and $serviceType = 'fibreInternet'">
                    &CSCMapping_FibreInternet;
                    &CSCMapping;
                  </xsl:when>
		            <xsl:when test="$accessType = 'businessDSL' and $functionType = 'internet'">
		              &CSCMapping_BusinessDSL;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'sipTrunk' and $functionType = 'voice'">
		              &CSCMapping_SIPTrunk;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'oneNetBusiness' and $functionType = 'voice'">
		              &CSCMapping_OneNetBusiness;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdn' and $functionType = 'voice' and $childServiceCode = 'V0113'">
		              &CSCMapping_ISDNDSL;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdn' and $functionType = 'voice'">
		              &CSCMapping_ISDN;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdn' and $functionType = 'internet'">
		              &CSCMapping_Online;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'voice' and $childServiceCode = 'V0113'">
		              &CSCMapping_ISDNDSL;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'voice'">
		              &CSCMapping_ISDNP2P;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'extraLine'">
		              &CSCMapping_ISDNP2PExtraLine;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'isdnP2P' and $functionType = 'internet'">
		              &CSCMapping_Online;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'lte' and $functionType = 'voice'">
		              &CSCMapping_LTEVoice;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'lte' and $functionType = 'internet'">
		              &CSCMapping_LTEInternet;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'ipBitstream' and $functionType = 'voice'">
		              &CSCMapping_BitVoIP;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'ipBitstream' and $functionType = 'internet' and $accessConfigurationType != 'businessIpBitstream'">
		              &CSCMapping_BitDSL;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'ngn' and $functionType = 'voice'">
		              &CSCMapping_NGNVoIP;
		              &CSCMapping;
		            </xsl:when>
                  <xsl:when test="$accessType = 'ngn' and $functionType = 'internet' and $serviceType = 'fibreInternet'">
                    &CSCMapping_FibreInternet;
                    &CSCMapping;
                  </xsl:when>
		            <xsl:when test="$accessType = 'ngn' and $functionType = 'internet'">
		              &CSCMapping_NGNDSL;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$accessType = 'sip' and $functionType = 'voice'">
		              &CSCMapping_VoIP2ndLine;
		              &CSCMapping;
		            </xsl:when>
                  <xsl:when test="$accessType = 'businessVoip' and $childServiceCode = 'VI081'">
                    &CSCMapping_ReferenceOrder;
				        &CSCMapping;
                  </xsl:when>
                  <xsl:when test="$accessType = 'businessVoip'">
				        &CSCMapping_BusinessVoIP;
				        &CSCMapping;
                  </xsl:when>
		            <xsl:when test="$functionType = 'hardware' and $serviceCode != ''">
		              &CSCMapping_Hardware;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$functionType = 'directoryEntry'">
		              &CSCMapping_DirectoryEntry;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$functionType = 'extraNumbers'">
		              &CSCMapping_ExtraNumbers;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$functionType = 'tvCenter'">
		              &CSCMapping_TVCenter;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$functionType = 'safetyPackage'">
		              &CSCMapping_SafetyPackage;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$serviceCode = '' and $productCode = 'VI201'">
		              &CSCMapping_VoIP2ndLine;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$serviceCode = '' and $productCode = 'I1410'">
		              &CSCMapping_SafetyPackage;
		              &CSCMapping;
		            </xsl:when>
		             <!-- For Business-Internet-Regio -->
            		<xsl:when test="$accessType = 'ipBitstream' and $functionType = 'internet' and $accessConfigurationType = 'businessIpBitstream'">
            		  &CSCMapping_BusinessInternetRegio;
             		  &CSCMapping;
           			</xsl:when>
		            <xsl:when test="$serviceCode != '' and $isServiceCodeHardware = 'Y'">
		              &CSCMapping_Hardware;
		              &CSCMapping;
		            </xsl:when>
		            <xsl:when test="$serviceCode = 'V8042'">
		              &CSCMapping_InstantAccess;
		              &CSCMapping;
		            </xsl:when>
                    <xsl:when test="$serviceCode = '' and
                      ($childServiceCode = 'I1217' or
                      $childServiceCode = 'I1218' or
                      $childServiceCode = 'I1220' or
                      $childServiceCode = 'I1221' or
                      $childServiceCode = 'I1224')">
                      &CSCMapping_IPCentrexBandwidth;
                      &CSCMapping;
                    </xsl:when>
                    <xsl:when test="$serviceCode = '' and
                      ($childServiceCode = 'V1091' or
                      $childServiceCode = 'V1092')">
                      &CSCMapping_SIPTrunk;
                      &CSCMapping;
                    </xsl:when>
                    <xsl:when test="$serviceCode = '' and $childServiceCode = 'V0850'">
                      &CSCMapping_HardwareBundle;
                      &CSCMapping;
                    </xsl:when>
                    <xsl:when test="$functionType = 'mobileUsage'">
              		  &CSCMapping_MobileUsage;
                      &CSCMapping;
                    </xsl:when>
		          </xsl:choose>
                </xsl:if>
              </xsl:for-each>
                <xsl:if test="$childServiceCode = ''
                    and $isServiceCodeHardware != 'Y'
                    and $serviceCode != 'V8042'
                    and $serviceCode != 'V0014'
                    and $productCode != 'I1410'
                    and $functionType != 'safetyPackage'
                    and $functionType != 'extraNumbers'
                    and $functionType != 'extraLine'
                    and $functionType != 'hardware'
                    and $functionType != 'directoryEntry'
                    and $functionType != 'mobileUsage'">
                    <!-- Aktivierungsdatum -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0909</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">
                            <xsl:value-of select="$activationDateOPM" />
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$isServiceCodeHardware = 'Y'">
                    <!-- Aktivierungsdatum -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0008</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">
                            <xsl:text>Hardware Umkonfiguration. Transaction ID: </xsl:text>
                            <xsl:value-of select="request-param[@name='transactionID']"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
            <xsl:if test ="request-param[@name='processingStatus'] = 'completedOPM'">
                <xsl:element name="allow_stp_modification">Y</xsl:element>
                <xsl:element name="ignore_empty_char_list">Y</xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
  
        <xsl:choose>
          <xsl:when test="request-param[@name='assignCustomerOrder'] = 'N'">
            <!-- Write the main access service to the external Notification -->
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
              <xsl:element name="command_id">create_notification_1</xsl:element>
              <xsl:element name="CcmFifCreateExternalNotificationInCont">
                <xsl:element name="effective_date">
                  <xsl:value-of select="$today"/>
                </xsl:element>
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="processed_indicator">Y</xsl:element>
                <xsl:element name="notification_action_name">
                  <xsl:value-of select="//request/action-name"/>
                </xsl:element>
                <xsl:element name="target_system">FIF</xsl:element>
                <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">
                      <xsl:value-of select="request-param[@name='functionID']"/>
                      <xsl:text>_SERVICE_TICKET_POSITION_ID</xsl:text>
                    </xsl:element>
                    <xsl:element name="parameter_value_ref">
                      <xsl:element name="command_id">reconf_main_service</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_customer_order</xsl:element>
              <xsl:element name="CcmFifReadExternalNotificationInCont">
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="parameter_name">
                  <xsl:choose>
                    <xsl:when test="request-param[@name='alternativeFunctionID'] != ''">
                      <xsl:value-of select="request-param[@name='alternativeFunctionID']"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="request-param[@name='functionID']"/>
                    </xsl:otherwise>
                  </xsl:choose>                
                  <xsl:if test="request-param[@name='useTerminationCustomerOrder'] = 'Y'">
                    <xsl:text>_TERM</xsl:text>
                  </xsl:if>
                  <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
                </xsl:element>
                <xsl:element name="ignore_empty_result">Y</xsl:element>
                <xsl:if test="request-param[@name='useExistingServiceTicketPosition'] = 'Y'">
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">find_open_stp</xsl:element>
                    <xsl:element name="field_name">stp_found</xsl:element>
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:element>
  
            <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
              <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
                <xsl:element name="customer_order_id_ref">
                  <xsl:element name="command_id">read_customer_order</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
                <xsl:element name="service_ticket_pos_list">
                  <xsl:element name="CcmFifCommandRefCont">
                    <xsl:element name="command_id">reconf_main_service</xsl:element>
                    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
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
  
            <xsl:if test="request-param[@name='dependentRelease'] = 'Y'">
              <!-- find an open customer order for the main service -->
              <xsl:element name="CcmFifFindCustomerOrderCmd">
                <xsl:element name="command_id">find_customer_order</xsl:element>
                <xsl:element name="CcmFifFindCustomerOrderInCont">
                  <xsl:element name="service_subscription_id_ref">
                    <xsl:element name="command_id">find_main_service</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="state_list">
                    <xsl:element name="CcmFifPassingValueCont">
                      <xsl:element name="value">RELEASED</xsl:element>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="allow_children">N</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            
            <!-- Create Customer Order for everything -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
              <xsl:element name="command_id">create_co</xsl:element>
              <xsl:element name="CcmFifCreateCustOrderInCont">
                <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_main_service</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:element name="cust_order_description">Umkonfiguration</xsl:element>
                <xsl:element name="customer_tracking_id">
                  <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                </xsl:element>
                <xsl:element name="lan_path_file_string">
                  <xsl:value-of select="request-param[@name='lanPathFileString']"/>
                </xsl:element>
                <xsl:element name="sales_rep_dept">
                  <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
                </xsl:element>
                <xsl:element name="provider_tracking_no">
                  <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
                </xsl:element>
                <xsl:element name="super_customer_tracking_id">
                  <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
                </xsl:element>
                <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                <xsl:element name="scan_date">
                  <xsl:value-of select="request-param[@name='scanDate']"/>
                </xsl:element>
                <xsl:element name="order_entry_date">
                  <xsl:value-of select="request-param[@name='entryDate']"/>
                </xsl:element>
                <xsl:element name="service_ticket_pos_list">
                  <!-- Reconfiguration of main access service -->
                  <xsl:element name="CcmFifCommandRefCont">
                    <xsl:element name="command_id">reconf_main_service</xsl:element>
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
  
            <xsl:if test="request-param[@name='processingStatus'] = ''">
  
              <xsl:variable name="releaseDelayDate">
                <xsl:choose>
                  <xsl:when test="request-param[@name='releaseDelayDate'] = ''"/>
                  <!-- today as release delay date doesn't make sense, 
                    therefore it's defaulted to no delay -->
                  <xsl:when test="request-param[@name='releaseDelayDate'] = 'today'"/>
                  <xsl:when test="request-param[@name='releaseDelayDate'] = 'tomorrow'">
                    <xsl:value-of select="$tomorrow"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="request-param[@name='releaseDelayDate']"/>
                  </xsl:otherwise>                                
                </xsl:choose>
              </xsl:variable>
                       
              <xsl:choose>   
                <xsl:when test="request-param[@name='dependentRelease'] != 'Y'">
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
                      <xsl:element name="release_delay_date">
                        <xsl:value-of select="$releaseDelayDate"/>	
                      </xsl:element>           
                    </xsl:element>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <!-- If no customer order is found, the customer order is just released
                    (if requested also with delay) -->
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
                      <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                      <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">find_customer_order</xsl:element>
                        <xsl:element name="field_name">customer_order_found</xsl:element>           
                      </xsl:element>
                      <xsl:element name="required_process_ind">N</xsl:element> 
                      <xsl:element name="release_delay_date">
                        <xsl:value-of select="$releaseDelayDate"/>	
                      </xsl:element>           
                    </xsl:element>
                  </xsl:element>
                  <!-- If a customer order is found, the customer order is released dependently 
                    (without delay, even if requested) -->
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
                      <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                      <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">find_customer_order</xsl:element>
                        <xsl:element name="field_name">customer_order_found</xsl:element>           
                      </xsl:element>
                      <xsl:element name="required_process_ind">Y</xsl:element> 
                      <xsl:element name="parent_customer_order_id_ref">
                        <xsl:element name="command_id">find_customer_order</xsl:element>
                        <xsl:element name="field_name">customer_order_id</xsl:element>              
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:otherwise>                                          
              </xsl:choose>
            </xsl:if>
  
            <!-- Write the main access service to the external Notification -->
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
              <xsl:element name="command_id">create_notification_1</xsl:element>
              <xsl:element name="CcmFifCreateExternalNotificationInCont">
                <xsl:element name="effective_date">
                  <xsl:value-of select="$today"/>
                </xsl:element>
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="processed_indicator">Y</xsl:element>
                <xsl:element name="notification_action_name">
                  <xsl:value-of select="//request/action-name"/>
                </xsl:element>
                <xsl:element name="target_system">FIF</xsl:element>
                <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">
                      <xsl:value-of select="request-param[@name='functionID']"/>
                      <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
                    </xsl:element>
                    <xsl:element name="parameter_value_ref">
                      <xsl:element name="command_id">create_co</xsl:element>
                      <xsl:element name="field_name">customer_order_id</xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">create_co</xsl:element>
                  <xsl:element name="field_name">customer_order_created</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
  
        <!-- Create Contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">RECONF_FUNCTION</xsl:element>
            <xsl:element name="short_description">Dienständerung</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>Dienst </xsl:text>
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              <xsl:text> wurde</xsl:text>
              <xsl:if test="request-param[@name='scenarioInformation'] != ''">
                <xsl:text> für </xsl:text>
                <xsl:value-of select="request-param[@name='scenarioInformation']"/>
              </xsl:if>
              <xsl:text> umkonfiguriert.&#xA;TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text> (</xsl:text>
              <xsl:value-of select="request-param[@name='clientName']"/>
              <xsl:text>)&#xA;User: </xsl:text>
              <xsl:value-of select="request-param[@name='userName']"/>
              <xsl:if test="request-param[@name='rollenBezeichnung'] != ''">
                <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
              </xsl:if>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      
      </xsl:if>
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionID</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='functionID']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">ccbId</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionStatus</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:choose>
                  <xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">SUCCESS</xsl:when>
                  <xsl:when test="request-param[@name='skipReconfiguration'] = 'Y'">SUCCESS</xsl:when>
                  <xsl:otherwise>ACKNOWLEDGED</xsl:otherwise>                  
                </xsl:choose>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      


    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
