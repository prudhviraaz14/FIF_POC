<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated Change Bandwidth FIF request

  @author makuier
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="desiredDateOPM"
        select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>


      <!-- Ensure that either accessNumber or  serviceSubscriptionId are provided -->
      <xsl:if test="(request-param[@name='accessNumber'] = '') and
        (request-param[@name='serviceSubscriptionId'] = '')">
        
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">find_ss_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">At least serviceSubscriptionId or accessNumber must be provided!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
     
      <!-- Find Service Subscription --> 
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="((request-param[@name='accessNumber'] != '' )and
            (request-param[@name='serviceSubscriptionId'] = ''))">
            <xsl:element name="access_number">
              <xsl:value-of select="request-param[@name='accessNumber']"/>
            </xsl:element>
            <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="contract_number">
              <xsl:value-of select="request-param[@name='contractNumber']"/>
            </xsl:element>            
            <xsl:element name="technical_service_code">TOC_NONBILL</xsl:element>            
          </xsl:if>
          <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>
      
       <!-- Validate Product Subscription Count -->
	  <xsl:element name="CcmFifValidateProdSubsCountCmd">
	    <xsl:element name="command_id">valid_ps_count_1</xsl:element>
	    <xsl:element name="CcmFifValidateProdSubsCountInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
		</xsl:element>
	  </xsl:element>

      <!-- Validate upstream bandwidth -->
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] != request-param[@name='newUpstreamBandwidth']
               or request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth']">
        <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 1000'
               and request-param[@name='newUpstreamBandwidth'] != 'Standard'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 1000. Passed in value: <xsl:value-of select="request-param[@name='newUpstreamBandwidth']"/>. Allowed values: Standard.</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:if test="(request-param[@name='newDSLBandwidth'] = 'DSL 1500' or
        	           request-param[@name='newDSLBandwidth'] = 'DSL 2000')
               and request-param[@name='newUpstreamBandwidth'] != 'Standard'
               and request-param[@name='newUpstreamBandwidth'] != '384'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Invalid upstream bandwidth value passed in for <xsl:value-of select="request-param[@name='newDSLBandwidth']"/>. Passed in value: <xsl:value-of select="request-param[@name='newUpstreamBandwidth']"/>.Allowed values: Standard, 384.</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 3000'
               and request-param[@name='newUpstreamBandwidth'] != 'Standard'
               and request-param[@name='newUpstreamBandwidth'] != '512'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 3000. Passed in value: <xsl:value-of select="request-param[@name='newUpstreamBandwidth']"/>. Allowed values: Standard, 512</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 6000'
               and request-param[@name='newUpstreamBandwidth'] != 'Standard'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 6000. Passed in value: <xsl:value-of select="request-param[@name='newUpstreamBandwidth']"/>. Allowed values: Standard.</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 16000'
          and request-param[@name='newUpstreamBandwidth'] != 'Standard'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 16000. Passed in value: <xsl:value-of select="request-param[@name='newUpstreamBandwidth']"/>. Allowed values: Standard.</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>		
      </xsl:if>
	  
	  <!-- Validate Fastpath -->
      <xsl:if test="(request-param[@name='newFastPathFlag'] = 'Y') and 
					(request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth'])">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">fastpath_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for 'newFastPathFlag' parameter.  Fastpath can only be requested if the downstream bandwidth is not changing.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Reconfigure Service Subscription -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
          	<xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:element name="reason_rd">TDSL_FEAT_CHANGE</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Auftragsvariante -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1011</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Leistungsänderung</xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='salesOrganisationNumber'] != '' ">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0990</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth']">
                <!-- Bandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1004</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 1000'">
                  <xsl:element name="configured_value">1000</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 1500'">
                  <xsl:element name="configured_value">1500</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 2000'">
                  <xsl:element name="configured_value">2000</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 3000'">
                  <xsl:element name="configured_value">3000</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 6000'">
                  <xsl:element name="configured_value">6000</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 16000'">
                  <xsl:element name="configured_value">16000</xsl:element>
                </xsl:if>                				
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='oldUpstreamBandwidth'] != request-param[@name='newUpstreamBandwidth']">
              <!-- Upstream Bandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0092</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='newUpstreamBandwidth']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='changeTariff'] = 'Y'">
              <!-- Tariff -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1013</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='newTariff']"/>
                </xsl:element>
              </xsl:element>
			  <!-- Change Tariff -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1012</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">Ja</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='changeTariff'] != 'Y'">
              <!-- Reset of Change Tariff flag -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1012</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">Nein</xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Geringere Bandbreite akzeptiert? -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1005</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:if test="request-param[@name='acceptLowerBandwidth'] = 'Y'">
                <xsl:element name="configured_value">Ja</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='acceptLowerBandwidth'] != 'Y'">
                <xsl:element name="configured_value">Nein</xsl:element>
              </xsl:if>
            </xsl:element>
			<xsl:if test="(request-param[@name='oldFastPathFlag'] != request-param[@name='newFastPathFlag']) 
						   and (request-param[@name='oldDSLBandwidth'] = request-param[@name='newDSLBandwidth'])">
			  <!-- Fastpath, only change when downstream bandwidth remains the same -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1009</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
				<xsl:if test="request-param[@name='newFastPathFlag'] = 'Y'">
                  <xsl:element name="configured_value">Ja</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='newFastPathFlag'] != 'Y'">
                  <xsl:element name="configured_value">Nein</xsl:element>
				</xsl:if>
              </xsl:element>
            </xsl:if>
			<xsl:if test="request-param[@name='changeMinimumDuration'] = 'Y'">
              <!-- New minimum duration -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1014</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
				  <xsl:value-of select="request-param[@name='newMinPeriodDuration']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>		
			<xsl:if test="request-param[@name='changeMinimumDuration'] != 'Y'">
              <!-- New minimum duration -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1014</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">keine</xsl:element>
              </xsl:element>
            </xsl:if>					
			<xsl:if test="request-param[@name='addFeatureService'] = 'Y'">
              <!-- Feature Service Code -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1015</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
				  <xsl:value-of select="request-param[@name='featureServiceCode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>		
			<xsl:if test="request-param[@name='addFeatureService'] != 'Y'">
              <!-- Feature Service Code -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1015</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value"/>
              </xsl:element>
            </xsl:if>					
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for Reconfiguration of Main Access Service -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the Feature change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">DSL_R_CHANGE</xsl:element>
          <xsl:element name="short_description">Änderung Leistungsmerkmal DSLR</xsl:element>
          <xsl:element name="description_text_list">
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>Source: KBA (Auftrag)</xsl:text>
				  <!-- Only Downstream change -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] = request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='changeTariff'] != 'Y')">
				    <xsl:text>&#xA;GF: Bandbreitenwechsel</xsl:text>
				  </xsl:if>
				  <!-- Downstream and Upstream change -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] != request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='changeTariff'] != 'Y')">
				    <xsl:text>&#xA;GF: BBW-/Upstreamwechsel</xsl:text>
				  </xsl:if>
				  <!-- Downstream and tariif change -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] = request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='changeTariff'] = 'Y')">
				    <xsl:text>&#xA;GF: BBW-/Tarifwechsel</xsl:text>
				  </xsl:if>				  
				  <!-- Downstream, Upstream, Tariff change -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] != request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] != request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='changeTariff'] = 'Y')">
				    <xsl:text>&#xA;GF: BBW-/Upstream-/Tarifwechsel</xsl:text>
				  </xsl:if>
				  <!-- Only Upstream -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] = request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] != request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='changeTariff'] != 'Y')">
				    <xsl:text>&#xA;GF: Upstreamwechsel</xsl:text>
				  </xsl:if>
				  <!-- Upstream and Tariff change -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] = request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] != request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='changeTariff'] = 'Y')">
				    <xsl:text>&#xA;GF: Upstream-/Tarifwechsel</xsl:text>
				  </xsl:if>
				  <!-- Only FastPath -->
				  <xsl:if test="(request-param[@name='oldDSLBandwidth'] = request-param[@name='newDSLBandwidth'])
								and (request-param[@name='oldUpstreamBandwidth'] = request-param[@name='newUpstreamBandwidth'])
								and (request-param[@name='oldFastPathFlag'] != request-param[@name='newFastPathFlag'])">
				    <xsl:text>&#xA;GF: Fastpath-Änderung</xsl:text>
				  </xsl:if>
                  <xsl:text>&#xA;ProductSubscriptionNumber: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>&#xA;ContractNumber: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>&#xA;RollenBezeichnung: </xsl:text>
                  <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                  <xsl:text>&#xA;UserName: </xsl:text>
                  <xsl:value-of select="request-param[@name='userName']"/>
          		</xsl:element>
          	</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
