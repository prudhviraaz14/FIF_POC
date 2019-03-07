<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated Modify Access Number FIF request

  @author banania
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
     
      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='BLOCK_INTERNATIONAL_NUMBERS'] != ''
        and request-param[@name='BLOCK_INTERNATIONAL_NUMBERS'] != 'ADD' 
        and request-param[@name='BLOCK_INTERNATIONAL_NUMBERS'] != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for parameter 'BLOCK_INTERNATIONAL_NUMBERS' (Value: '<xsl:value-of select="request-param[@name='BLOCK_INTERNATIONAL_NUMBERS']"/>'). Allowed values are 'ADD' and 'REMOVE'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
  
      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS'] != '' 
        and request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS'] != 'ADD' 
        and request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS'] != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for parameter 'BLOCK_NON_EUROPEAN_NUMBERS' (Value: '<xsl:value-of select="request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS']"/>'). Allowed values are 'ADD' and 'REMOVE'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='BLOCK_PREMIUM_NUMBERS'] != '' 
        and request-param[@name='BLOCK_PREMIUM_NUMBERS'] != 'ADD' 
        and request-param[@name='BLOCK_PREMIUM_NUMBERS'] != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_3</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for parameter 'BLOCK_PREMIUM_NUMBERS' (Value: '<xsl:value-of select="request-param[@name='BLOCK_PREMIUM_NUMBERS']"/>'). Allowed values are 'ADD' and 'REMOVE'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='BLOCK_0137_CALLS'] != ''
        and request-param[@name='BLOCK_0137_CALLS'] != 'ADD' 
        and request-param[@name='BLOCK_0137_CALLS'] != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_4</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for parameter 'BLOCK_0137_CALLS' (Value: '<xsl:value-of select="request-param[@name='BLOCK_0137_CALLS']"/>'). Allowed values are 'ADD' and 'REMOVE'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='BLOCK_SELECTED_NUMBERS'] != '' 
        and request-param[@name='BLOCK_SELECTED_NUMBERS'] != 'ADD' 
        and request-param[@name='BLOCK_SELECTED_NUMBERS'] != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_5</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for parameter 'BLOCK_SELECTED_NUMBERS' (Value: '<xsl:value-of select="request-param[@name='BLOCK_SELECTED_NUMBERS']"/>'). Allowed values are 'ADD' and 'REMOVE'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='BLOCK_MOBILE_NUMBERS'] != ''
        and request-param[@name='BLOCK_MOBILE_NUMBERS'] != 'ADD' 
        and request-param[@name='BLOCK_MOBILE_NUMBERS'] != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_6</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid value for parameter 'BLOCK_MOBILE_NUMBERS' (Value: '<xsl:value-of select="request-param[@name='BLOCK_MOBILE_NUMBERS']"/>'). Allowed values are 'ADD' and 'REMOVE'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>                            
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>       
      <xsl:variable name="DesiredDate">
        <xsl:choose>
          <xsl:when test="request-param[@name='DESIRED_DATE'] != ''
            and dateutils:compareString(request-param[@name='DESIRED_DATE'], $today) = '-1'">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$today"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>	
                     
      <!-- Find main service subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="request-param[@name='VOICE_SERVICE_ID']"/>
          </xsl:element>
          <xsl:element name="access_number_type">TECH_SERVICE_ID</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='BLOCK_INTERNATIONAL_NUMBERS'] != ''">        
        <!-- Find child Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_block_international_num_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">Wh018</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>						
          </xsl:element>
        </xsl:element> 
        <xsl:if test="request-param[@name='BLOCK_INTERNATIONAL_NUMBERS'] = 'REMOVE'">
          <!-- Terminate Blocking Service for "Wholesale Sperre - Ausland" if not exists -->           
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_block_international_num_service</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">Wh018</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_international_num_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:if test="request-param[@name='BLOCK_INTERNATIONAL_NUMBERS'] = 'ADD'">
            <!-- Add New Blocking Service for "Wholesale Sperre - Ausland" if found  -->         
          <xsl:element name="CcmFifAddServiceSubsCmd">
              <xsl:element name="command_id">add_block_international_num_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">Wh018</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>              
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_international_num_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>

      <xsl:if test="request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS'] != ''">        
        <!-- Find child Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_block_non_european_num_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">Wh017</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>						
          </xsl:element>
        </xsl:element>
        <xsl:if test="request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS'] = 'REMOVE'">
          <!-- Terminate Blocking Service for "Wholesale Sperre - außerhalb EU" if found -->           
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_block_non_european_num_service</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">Wh017</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_non_european_num_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:if> 
        <xsl:if test="request-param[@name='BLOCK_NON_EUROPEAN_NUMBERS'] = 'ADD'">
          <!-- Add New Blocking Service for "Wholesale Sperre - außerhalb EU" if not exists -->         
          <xsl:element name="CcmFifAddServiceSubsCmd">
              <xsl:element name="command_id">add_block_non_european_num_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">Wh017</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>              
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_non_european_num_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>       
      </xsl:if> 
          
      <xsl:if test="request-param[@name='BLOCK_PREMIUM_NUMBERS'] != ''">        
        <!-- Find child Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_block_premium_nums_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">Wh016</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>						
          </xsl:element>
        </xsl:element>        
        <xsl:if test="request-param[@name='BLOCK_PREMIUM_NUMBERS'] = 'REMOVE'">
          <!-- Terminate Blocking Service for "Wholesale Sperre - 0190/0900" if found -->           
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_block_premium_nums_service</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">Wh016</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_premium_nums_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:if>         
        <xsl:if test="request-param[@name='BLOCK_PREMIUM_NUMBERS'] = 'ADD'">
          <!-- Add New Blocking Service for "Wholesale Sperre - 0190/0900" if not exists -->                   
          <xsl:element name="CcmFifAddServiceSubsCmd">
              <xsl:element name="command_id">add_block_premium_nums_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">Wh016</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>              
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_premium_nums_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>

      <xsl:if test="request-param[@name='BLOCK_0137_CALLS'] != ''">        
        <!-- Find child Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_block_0137_calls_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">Wh015</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>						
          </xsl:element>
        </xsl:element>
        <xsl:if test="request-param[@name='BLOCK_0137_CALLS'] = 'REMOVE'">
          <!-- Terminate Blocking Service for "Wholesale Sperre 0137" if found -->           
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_block_0137_calls_service</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">Wh015</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_0137_calls_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:if>           
        <xsl:if test="request-param[@name='BLOCK_0137_CALLS'] = 'ADD'">
          <!-- Add New Blocking Service for "Wholesale Sperre 0137" if not exists -->                   
          <xsl:element name="CcmFifAddServiceSubsCmd">
              <xsl:element name="command_id">add_block_0137_calls_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">Wh015</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>              
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_0137_calls_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>

      <xsl:if test="request-param[@name='BLOCK_SELECTED_NUMBERS'] != ''">        
        <!-- Find child Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_block_selected_nums_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">Wh014</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>						
          </xsl:element>
        </xsl:element>
        <xsl:if test="request-param[@name='BLOCK_SELECTED_NUMBERS'] = 'REMOVE'">
          <!-- Terminate Blocking Service for "Wholesale Sperre ausgewählter Sonderrufnummern" if found -->           
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_block_selected_nums_service</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">Wh014</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_selected_nums_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:if>  
        <xsl:if test="request-param[@name='BLOCK_SELECTED_NUMBERS'] = 'ADD'">
          <!-- Add New Blocking Service for "Wholesale Sperre ausgewählter Sonderrufnummern" if not exists -->                   
          <xsl:element name="CcmFifAddServiceSubsCmd">
              <xsl:element name="command_id">add_block_selected_nums_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">Wh014</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>              
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_selected_nums_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>

      <xsl:if test="request-param[@name='BLOCK_MOBILE_NUMBERS'] != ''">        
        <!-- Find child Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_block_mobile_nums_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">Wh013</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>						
          </xsl:element>
        </xsl:element>
        <xsl:if test="request-param[@name='BLOCK_MOBILE_NUMBERS'] = 'REMOVE'">
          <!-- Terminate Blocking Service for "Wholesale Sperre Mobilfunk (015x, 016x, 017x)" if found -->           
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_block_mobile_nums_service</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">Wh013</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_mobile_nums_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:if>  
        <xsl:if test="request-param[@name='BLOCK_MOBILE_NUMBERS'] = 'ADD'">
          <!-- Add New Blocking Service for "Wholesale Sperre Mobilfunk (015x, 016x, 017x)" if not exists -->                   
          <xsl:element name="CcmFifAddServiceSubsCmd">
              <xsl:element name="command_id">add_block_mobile_nums_service</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">Wh013</xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>              
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_block_mobile_nums_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
              <xsl:element name="service_characteristic_list"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>      


      <!-- Create Customer Order for termination of old services and adding of new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>                  
        <!--  <xsl:element name="provider_tracking_no">?</xsl:element>--> 
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>          
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_block_international_num_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_block_non_european_num_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_block_premium_nums_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_block_0137_calls_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_block_selected_nums_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_block_mobile_nums_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_block_international_num_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_block_non_european_num_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_block_premium_nums_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_block_0137_calls_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_block_selected_nums_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_block_mobile_nums_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>  
          </xsl:element>                               
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>    
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>  

      <!-- Create Contact for the blocking -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">MODIFY_NUM_BLOCK</xsl:element>
          <xsl:element name="short_description">Änderung Rufnummernsperre</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;User name: </xsl:text>
                <xsl:value-of select="request-param[@name='USER_NAME']"/>
                <xsl:text>&#xA;Client name: </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>&#xA;Interner Auftrag erstellt: </xsl:text>
              </xsl:element> 
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element> 
      </xsl:element>

       
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
