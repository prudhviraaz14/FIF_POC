<xsl:variable name="CustomerIntention">
    <xsl:choose>
        <xsl:when test="request-param[@name='EARLY_TERMINATION'] = 'Y'">EarlyTermination</xsl:when>
        <xsl:when test="request-param[@name='OMTS_ORDER_ID_ACTIVATION'] != ''">ProviderChange</xsl:when>
        <xsl:otherwise>Termination</xsl:otherwise>
    </xsl:choose>    
</xsl:variable>

<xsl:element name="Command_List">
<!-- Generate a Termination SOM -->
      <xsl:element name="CcmFifTerminateServicesSOMCmd">
          <xsl:element name="command_id">term_service_som</xsl:element>
        <xsl:element name="CcmFifTerminateServicesSOMInCont">
          <xsl:element name="service_subscription_list">
              <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_subscription_id">
                      <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                  </xsl:element>
              </xsl:element>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="$TerminationDate"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
              <xsl:value-of select="request-param[@name='NOTICE_PERIOD_START_DATE']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>
          </xsl:element>
          <xsl:element name="termination_reason_rd">
              <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="customer_tracking_id">
              <xsl:value-of select="$OMTSOrderId"/>
          </xsl:element>
          <xsl:element name="omts_order_id_activation">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID_ACTIVATION']"/>
          </xsl:element>
          <xsl:element name="entry_user">
                <xsl:value-of select="request-param[@name='USER_NAME']"/>
          </xsl:element>
          <xsl:element name="entry_system">OPM</xsl:element>
          <xsl:element name="customer_intention">
              <xsl:value-of select="$CustomerIntention"/>
          </xsl:element>
          <xsl:element name="line_take_over">
              <xsl:value-of select="request-param[@name='lineTakeOverIndicator']"/>
          </xsl:element>
          <xsl:element name="precoordination_id">
              <xsl:value-of select="request-param[@name='WBCIpreCoordinationId']"/>
          </xsl:element>
          <xsl:element name="safety_termination">
              <xsl:value-of select="request-param[@name='WBCIsafetyTerminationFlagIndicator']"/>
          </xsl:element>              
            <xsl:element name="port_access_number_1">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_1']"/>
            </xsl:element>            
            <xsl:element name="port_access_number_2">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_2']"/>
            </xsl:element>
            <xsl:element name="port_access_number_3">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_3']"/>
            </xsl:element>
            <xsl:element name="port_access_number_4">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_4']"/>
            </xsl:element>
            <xsl:element name="port_access_number_5">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_5']"/>
            </xsl:element>
            <xsl:element name="port_access_number_6">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_6']"/>
            </xsl:element>
            <xsl:element name="port_access_number_7">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_7']"/>
            </xsl:element>
            <xsl:element name="port_access_number_8">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_8']"/>
            </xsl:element>
            <xsl:element name="port_access_number_9">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_9']"/>
            </xsl:element>
            <xsl:element name="port_access_number_10">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_10']"/>
            </xsl:element>
            <xsl:element name="port_access_number_range_1">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_RANGE_1']"/>
            </xsl:element>
            <xsl:element name="port_access_number_range_2">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_RANGE_2']"/>
            </xsl:element>
            <xsl:element name="port_access_number_range_3">
                <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_RANGE_3']"/>
            </xsl:element>
            <xsl:element name="carrier">
                <xsl:value-of select="request-param[@name='CARRIER']"/>
            </xsl:element>
            <xsl:if test="request-param[@name='OMTS_ORDER_ID_ACTIVATION '] = ''">
                <xsl:element name="order_variant">Echte Kündigung</xsl:element>
            </xsl:if>
         </xsl:element>       
      </xsl:element>
</xsl:element>	
