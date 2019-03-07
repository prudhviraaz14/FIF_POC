<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for writing to External Notification

  @author Marcin Leja
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
    <xsl:element name="client_name">CCM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <xsl:variable name="ServiceTicketPositionId" select="request-param[@name='PROCESSING_MODE']" />
      <xsl:variable name="FindServCharValueForServChar">find_serv_char_value_</xsl:variable>
      <xsl:variable name="CreatePermNotification">create_external_notification_</xsl:variable>
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
      <xsl:variable name="oneDayAfter"
        select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
      
      <xsl:if test="(request-param[@name='PROCESSING_MODE'] != 'ADD'
        and request-param[@name='PROCESSING_MODE'] != 'REPLACE')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">old_dsl_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Parameter PROCESSING_MODE must have value ADD or REPLACE.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Find the Service Subscription for BitVoIP -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate service subscription is BitVoIP -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_service_code_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICE_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">SERVICE_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VI006</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VI009</xsl:element>          	  
            </xsl:element>
          </xsl:element>
          <xsl:element name="ignore_failure_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raise_error</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text">ModifyVoIP allowned only for BIT-VoIP services: VI006 (Premium) or VI009 (Basis)!</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_service_code_1</xsl:element>
            <xsl:element name="field_name">success_ind</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate service subscription is BitVoIP Basic -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_service_code_2</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICE_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">SERVICE_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VI009</xsl:element>          	  
            </xsl:element>
          </xsl:element>
          <xsl:element name="ignore_failure_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_sc_move_num_mode</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">serviceCode;moveNumbersMode</xsl:element>
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_code</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">;</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">							
                <xsl:value-of select="request-param[@name='PROCESSING_MODE']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type"></xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">VI006;ADD</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">VI006;REPLACE</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">VI009;ADD</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">VI009;REPLACE</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raise_error_val_1</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text">Parameter PROCESSING_MODE for Basis is only allowed with mode REPLACE, not ADD.</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_sc_move_num_mode</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find the Service Subscription for BitVoIP -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_val_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
          <xsl:element name="target_state">SUBSCRIBED</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find the Service Subscription source VoIP (VoIPndLine)-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_val_2</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SOURCE_SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
          <xsl:element name="target_state">TERMINATED</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- If either subscribed BitVoIP and terminated VoIP2ndLine has not been found shift reqest one day -->
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_shift_tran</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_val_1</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">;</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_val_2</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type"></xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">Y;Y</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">N;Y</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">Y;N</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">N;N</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- create a copy of ccm_fif_request for modifyVoIP transaction for next day-->
      <xsl:element name="CcmFifCreateFifRequestCmd">
        <xsl:element name="command_id">create_fif_request_1</xsl:element> 
        <xsl:element name="CcmFifCreateFifRequestInCont">
          <xsl:element name="action_name">modifyVoIP</xsl:element> 
          <xsl:element name="due_date">
            <xsl:value-of select="$today"/>
          </xsl:element> 
          <xsl:element name="offset_days">1</xsl:element> 
          <xsl:element name="dependent_transaction_id">dummy</xsl:element>
          <xsl:element name="priority">6</xsl:element>
          <xsl:element name="bypass_command">N</xsl:element>
          <xsl:element name="external_system_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="request_param_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SOURCE_SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='SOURCE_SERVICE_SUBSCRIPTION_ID']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PROCESSING_MODE</xsl:element> 
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='PROCESSING_MODE']"/>
              </xsl:element>
            </xsl:element>                 
          </xsl:element>                 
          <xsl:element name="additional_param_list_name">ACCESS_NUMBER_LIST</xsl:element>            
          <xsl:element name="additional_param_list">           
            <xsl:for-each select="request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item">
              <xsl:variable name="Count" select="position()"/>
              <xsl:variable name="ParamName" select="concat('ACCESS_NUMBER_', $Count)"/>
              <xsl:variable name="ParamValue" select="."/>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">
                  <xsl:value-of select="$ParamName"/>
                </xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$ParamValue"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>          
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_shift_tran</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>										
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">ACCNUM_FROM_QUAR</xsl:element>
          <xsl:element name="short_description">Takeover quarantined ANs</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;Transactiion shifted one day since either BitVoIP </xsl:text>
                <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                <xsl:text>&#xA;is not subscribed or VoIP2ndLine </xsl:text>
                <xsl:value-of select="request-param[@name='SOURCE_SERVICE_SUBSCRIPTION_ID']"/>
                <xsl:text>&#xA;is not terminated. Next due_date </xsl:text>
                <xsl:value-of select="$oneDayAfter"/>
              </xsl:element> 
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_shift_tran</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>										
        </xsl:element> 
      </xsl:element>		
      
      <xsl:if test="count(request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item) != 0">
        
        <xsl:if test="request-param[@name='PROCESSING_MODE'] = 'REPLACE'">

          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">concat_ss_shift_tran</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">service_code</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">map_shift_tran</xsl:element>
                  <xsl:element name="field_name">output_string</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Reconfigure Service Subscription : Basic VI009 -->
          <xsl:element name="CcmFifReconfigServiceCmd">
            <xsl:element name="command_id">reconf_serv_1</xsl:element>
            <xsl:element name="CcmFifReconfigServiceInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">PORT_ACCESS_NUM</xsl:element>
              <xsl:element name="service_characteristic_list">
                <!-- Grund der Konfiguration -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI008</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">Rufnummernänderung</xsl:element>
                </xsl:element>
                <!-- Bearbeitungsart -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI002</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">OP</xsl:element>
                </xsl:element>
                <xsl:for-each select="request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item">
                  <xsl:variable name="Count" select="position()"/>
                  <xsl:if test="$Count = 1">
                    <!-- Portierung -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">V0165</xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">ja</xsl:element>
                    </xsl:element>
                    <!-- Reconfigure Access Number -->
                    <xsl:element name="CcmFifAccessNumberCont">
                      <xsl:element name="service_char_code">V0001</xsl:element>
                      <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                      <xsl:element name="masking_digits_rd">0</xsl:element>
                      <xsl:element name="retention_period_rd">80NODT</xsl:element>
                      <xsl:element name="storage_masking_digits_rd">0</xsl:element>
                      <xsl:element name="country_code">
                        <xsl:value-of select="substring-before(request-param[@name='ACCESS_NUMBER_1'], ';')"/>
                      </xsl:element>
                      <xsl:element name="city_code">
                        <xsl:value-of select="substring-before(substring-after(request-param[@name='ACCESS_NUMBER_1'],';'), ';')"/>
                      </xsl:element>
                      <xsl:element name="local_number">
                        <xsl:value-of select="substring-after(substring-after(request-param[@name='ACCESS_NUMBER_1'],';'), ';')"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>  
                </xsl:for-each>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">concat_ss_shift_tran</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">VI009;Y</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Reconfigure Service Subscription : Premium VI006 -->
          <xsl:element name="CcmFifReconfigServiceCmd">
            <xsl:element name="command_id">reconf_serv_1</xsl:element>
            <xsl:element name="CcmFifReconfigServiceInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">PORT_ACCESS_NUM</xsl:element>
              <xsl:element name="service_characteristic_list">
                <!-- Grund der Konfiguration -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI008</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">Rufnummernänderung</xsl:element>
                </xsl:element>
                <!-- Bearbeitungsart -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI002</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">OP</xsl:element>
                </xsl:element>
                <xsl:for-each select="request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item">
                  <xsl:sort select="@name"/>
                  <xsl:variable name="Count" select="position()"/>
                  <xsl:variable name="CountServCode" select="position()+68"/>
                  <xsl:variable name="CountPortInd" select="position()+164"/>
                  <xsl:variable name="ServCode" select="concat('V00', $CountServCode)"/>
                  <xsl:variable name="PortingIndServCode" select="concat('V0', $CountPortInd)"/>
                  <xsl:variable name="NewAccessNumber" select="."/>
                  <xsl:if test="(($CountServCode &gt; 68) and ($CountServCode &lt; 79))">
                    <!-- Portierung -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">
                        <xsl:value-of select="$PortingIndServCode"/>
                      </xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">ja</xsl:element>
                    </xsl:element>
                    <!-- Reconfigure Access Number -->
                    <xsl:element name="CcmFifAccessNumberCont">
                      <xsl:if test="($CountServCode = 69)">
                         <xsl:element name="service_char_code">V0001</xsl:element>
                       </xsl:if>  
                      <xsl:if test="($CountServCode != 69)">
                        <xsl:element name="service_char_code">
                          <xsl:value-of select="$ServCode"/>
                        </xsl:element>
                      </xsl:if>  
                      <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                      <xsl:element name="masking_digits_rd">0</xsl:element>
                      <xsl:element name="retention_period_rd">80NODT</xsl:element>
                      <xsl:element name="storage_masking_digits_rd">0</xsl:element>
                      <xsl:element name="country_code">
                        <xsl:value-of select="substring-before($NewAccessNumber, ';')"/>
                      </xsl:element>
                      <xsl:element name="city_code">
                        <xsl:value-of select="substring-before(substring-after($NewAccessNumber,';'), ';')"/>
                      </xsl:element>
                      <xsl:element name="local_number">
                        <xsl:value-of select="substring-after(substring-after($NewAccessNumber,';'), ';')"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>  
                </xsl:for-each>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">concat_ss_shift_tran</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">VI006;Y</xsl:element>
            </xsl:element>
          </xsl:element>

        </xsl:if>
        
        <xsl:if test="request-param[@name='PROCESSING_MODE'] = 'ADD'">

          <xsl:variable name="numOfNewANs" select="count(request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item)"/>
          
          <!-- Get available access number CSCs for Premium VI006 -->
          <xsl:element name="CcmFifValAccessNumbersCmd">
            <xsl:element name="command_id">val_access_number_1</xsl:element>
            <xsl:element name="CcmFifValAccessNumbersInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="ported_new_ans">
                <xsl:for-each select="request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item">
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="value">
                      <xsl:value-of select="request-param[@name='newAccessNumber']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
              <xsl:element name="main_access_ind">Y</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Reconfigure Service Subscription : Premium VI006 -->
          <xsl:element name="CcmFifReconfigServiceCmd">
            <xsl:element name="command_id">reconf_serv_1</xsl:element>
            <xsl:element name="CcmFifReconfigServiceInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">PORT_ACCESS_NUM</xsl:element>
              <xsl:element name="service_characteristic_list">
                <!-- Grund der Konfiguration -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI008</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">Rufnummernänderung</xsl:element>
                </xsl:element>
                <!-- Bearbeitungsart -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">VI002</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">OP</xsl:element>
                </xsl:element>
                <xsl:for-each select="request-param-list[@name='ACCESS_NUMBER_LIST']/request-param-list-item">
                  <xsl:sort select="@name"/>
                  <xsl:variable name="Count" select="position()"/>
                  <xsl:variable name="NewAccessNumber" select="."/>
                    <!-- Portierung -->
                  <xsl:variable name="PortIndFieldName" select="concat('port_ind_service_code_', $Count)"/>
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code_ref">
                      <xsl:element name="command_id">val_access_number_1</xsl:element>
                      <xsl:element name="field_name">
                        <xsl:value-of select="$PortIndFieldName"/>
                      </xsl:element>
                    </xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">ja</xsl:element>
                  </xsl:element>
                  <!-- Reconfigure Access Number -->
                  <xsl:variable name="FieldName" select="concat('available_service_code_', $Count)"/>
                  <xsl:element name="CcmFifAccessNumberCont">
                    <xsl:element name="service_char_code_ref">
                      <xsl:element name="command_id">val_access_number_1</xsl:element>
                      <xsl:element name="field_name">
                        <xsl:value-of select="$FieldName"/>
                      </xsl:element>
                    </xsl:element>
                    <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                    <xsl:element name="masking_digits_rd">0</xsl:element>
                    <xsl:element name="retention_period_rd">80NODT</xsl:element>
                    <xsl:element name="storage_masking_digits_rd">0</xsl:element>
                    <xsl:element name="country_code">
                      <xsl:value-of select="substring-before($NewAccessNumber, ';')"/>
                    </xsl:element>
                    <xsl:element name="city_code">
                      <xsl:value-of select="substring-before(substring-after($NewAccessNumber,';'), ';')"/>
                    </xsl:element>
                    <xsl:element name="local_number">
                      <xsl:value-of select="substring-after(substring-after($NewAccessNumber,';'), ';')"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">map_shift_tran</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>										
              <xsl:element name="ignore_empty_csc_id">Y</xsl:element>
            </xsl:element>
          </xsl:element>

        </xsl:if>

        <!-- Generate Barcode -->     
        <xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
          <xsl:element name="command_id">generate_barcode_1</xsl:element>
        </xsl:element> 
        
        <!-- Create Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_tracking_id_ref">
              <xsl:element name="command_id">generate_barcode_1</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element> 
            <xsl:element name="provider_tracking_no">001</xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">reconf_serv_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>		        	
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_shift_tran</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>

        <!-- Release Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_shift_tran</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">ACCNUM_FROM_QUAR</xsl:element>
            <xsl:element name="short_description">Takeover quarantined ANs</xsl:element>
            <xsl:element name="description_text_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>TransactionID: </xsl:text>
                    <xsl:value-of select="request-param[@name='transactionID']"/>
                  <xsl:text>&#xA;Access numbers for service </xsl:text>
                     <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                  <xsl:text>&#xA;ported from service </xsl:text>
                    <xsl:value-of select="request-param[@name='SOURCE_SERVICE_SUBSCRIPTION_ID']"/>
                  <xsl:text>&#xA;on </xsl:text>
                    <xsl:value-of select="$today"/>
                  </xsl:element> 
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_shift_tran</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element> 
        </xsl:element>		

      </xsl:if>
      

      </xsl:element>
  </xsl:template>
</xsl:stylesheet>
