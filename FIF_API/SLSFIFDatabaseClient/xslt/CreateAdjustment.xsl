<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Create Adjustment FIF request

  @author goethalo
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">

      <xsl:if test="request-param[@name='PAYMENT_MODE'] != ''                              
        and request-param[@name='PAYMENT_MODE'] != 'INVOICE'
        and request-param[@name='PAYMENT_MODE'] != 'DIRECT'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_adjustment_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for the parameter PAYMENT_MODE: INVOICE or DIRECT.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- check, if the adjustment is a debit adjustment, otherwise raise an error, as
        the resolution user id is required in this case -->
      <xsl:if test="request-param[@name='RESOLUTION_USER_ID'] = ''
        and request-param[@name='CLIENT_NAME'] != 'OPM'">
        <xsl:element name="CcmFifGetGeneralCodeGroupCmd">
          <xsl:element name="command_id">check_debit_adjustment</xsl:element>
          <xsl:element name="CcmFifGetGeneralCodeGroupInCont">
            <xsl:element name="value">
              <xsl:value-of select="request-param[@name='REASON_CODE']"/>
            </xsl:element>
            <xsl:element name="group_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">ADJDEBIT</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if
        test="(request-param[@name='ACCOUNT_NUMBER'] = '') and (request-param[@name='CUSTOMER_NUMBER'] = '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_adjustment_error_3</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Either an account number or a customer number must be provided.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if
        test="(request-param[@name='ACCOUNT_NUMBER'] != '') and (request-param[@name='CUSTOMER_NUMBER'] != '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_adjustment_error_4</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Only one of the fields, customer number or account number, should be provider not both.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Create Adjustment -->
      <xsl:element name="CcmFifCreateAdjustmentCmd">
        <xsl:element name="command_id">create_adjustment_1</xsl:element>
        <xsl:element name="CcmFifCreateAdjustmentInCont">
          <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '')">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] = '')">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="start_date">
            <xsl:value-of select="request-param[@name='START_DATE']"/>
          </xsl:element>
          <xsl:element name="base_currency_amount">
            <xsl:value-of select="request-param[@name='AMOUNT']"/>
          </xsl:element>
          <xsl:element name="create_user_id">
            <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
          </xsl:element>
          <xsl:element name="description_text">
            <xsl:value-of select="request-param[@name='DESCRIPTION']"/>
          </xsl:element>
          <xsl:element name="reason_code">
            <xsl:value-of select="request-param[@name='REASON_CODE']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='REASON_CODE'] != '115TECE'">
            <xsl:element name="product_code">
              <xsl:value-of select="request-param[@name='PRODUCT_CODE']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='REASON_CODE'] = '115TECE'">
            <xsl:element name="product_code">Z0101</xsl:element>
          </xsl:if>
          <xsl:element name="tax_code">
            <xsl:value-of select="request-param[@name='TAX_CODE']"/>
          </xsl:element>
          <xsl:element name="internal_reason_text">
            <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='SALES_ORG_NUMBER']"/>
          </xsl:element>
          <xsl:element name="create_date">
            <xsl:value-of select="request-param[@name='CREATE_DATE']"/>
          </xsl:element>
          <xsl:element name="resolution_date">
            <xsl:value-of select="request-param[@name='RESOLUTION_DATE']"/>
          </xsl:element>
          <xsl:element name="resolution_user_id">
            <xsl:if test="request-param[@name='RESOLUTION_USER_ID'] = ''">
              <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
            </xsl:if>
            <xsl:if test="request-param[@name='RESOLUTION_USER_ID'] != ''">
              <xsl:value-of select="request-param[@name='RESOLUTION_USER_ID']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="child_customer_number">
            <xsl:value-of select="request-param[@name='CHILD_CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="invoice_id">
            <xsl:value-of select="request-param[@name='INVOICE_ID']"/>
          </xsl:element>
          <xsl:element name="condition_type">
            <xsl:value-of select="request-param[@name='CONDITION_TYPE']"/>
          </xsl:element>
          <xsl:element name="article_code">
            <xsl:value-of select="request-param[@name='ARTICLE_CODE']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>          
          <xsl:element name="unit_measure_enum">
            <xsl:value-of select="request-param[@name='UNIT_MEASURE_ENUM']"/>
          </xsl:element>          
          <xsl:element name="unit_volume">
            <xsl:value-of select="request-param[@name='UNIT_VOLUME']"/>
          </xsl:element> 
          <xsl:element name="external_product_id">
            <xsl:value-of select="request-param[@name='EXTERNAL_PRODUCT_ID']"/>
          </xsl:element>
          <xsl:element name="recurring_duration">
            <xsl:value-of select="request-param[@name='RECURRING_VALUE']"/>
          </xsl:element>   
          <xsl:element name="payment_mode">
            <xsl:value-of select="request-param[@name='PAYMENT_MODE']"/>
          </xsl:element> 
          <xsl:element name="kba_transaction_nr">
            <xsl:value-of select="request-param[@name='KBA_TRANSACTION_NR']"/>
          </xsl:element>          
          <xsl:element name="print">
            <xsl:value-of select="request-param[@name='PRINT']"/>
          </xsl:element> 
        </xsl:element>
      </xsl:element>

      <!-- get customer data -->
      <xsl:element name="CcmFifGetCustomerDataCmd">
        <xsl:element name="command_id">get_customer_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerDataInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_adjustment_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="no_customer_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
        
      <!-- Create Contact-->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact_1</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_adjustment_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">ADJUSTMENT</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
          </xsl:element>
          <xsl:element name="short_description">
            <xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_customer_data</xsl:element>
            <xsl:element name="field_name">state_rd</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">ACTIVATED</xsl:element> 
        </xsl:element>
      </xsl:element>

      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <!-- Get today's date -->
        <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:if test="request-param[@name='START_DATE'] != ''">
              <xsl:value-of select="request-param[@name='START_DATE']"/>
            </xsl:if>
            <xsl:if test="request-param[@name='START_DATE'] = ''">
              <xsl:value-of select="$today"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">create_adjustment_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">CONTACT</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CATEGORY</xsl:element>
              <xsl:element name="parameter_value">Adjustment</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">WORK_DATE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:if test="request-param[@name='START_DATE'] != ''">
                  <xsl:value-of select="request-param[@name='START_DATE']"/>
                </xsl:if>
                <xsl:if test="request-param[@name='START_DATE'] = ''">
                  <xsl:value-of select="$today"/>
                </xsl:if>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']" disable-output-escaping="yes"/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Bonus Adjustment -->
      <xsl:if test="(request-param[@name='CANVASSED_CUSTOMER'] != '')">
        <xsl:element name="CcmFifModifyCanvassedCustomerCmd">
          <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
          <xsl:element name="CcmFifModifyCanvassedCustomerInCont">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
            <xsl:element name="start_date">
              <xsl:value-of select="request-param[@name='START_DATE']"/>
            </xsl:element>
            <xsl:element name="create_date">
              <xsl:value-of select="request-param[@name='CREATE_DATE']"/>
            </xsl:element>
            <xsl:element name="create_user_id">
              <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
            </xsl:element>
            <xsl:element name="internal_reason_text">
              <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"/>
            </xsl:element>
            <xsl:element name="description">
			  <xsl:text>Vielwerber-</xsl:text>
              <xsl:value-of select="request-param[@name='DESCRIPTION']"/>
            </xsl:element>
            <xsl:element name="reason_code">
              <xsl:value-of select="request-param[@name='REASON_CODE']"/>
            </xsl:element>
            <xsl:element name="tax_code">
              <xsl:value-of select="request-param[@name='TAX_CODE']"/>
            </xsl:element>
            <xsl:element name="canvassed_customer">
              <xsl:value-of select="request-param[@name='CANVASSED_CUSTOMER']"/>
            </xsl:element>
            <xsl:element name="split_bonus">
              <xsl:value-of select="request-param[@name='SPLIT_BONUS']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Create Contact-->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact_2</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">ADJUSTMENT</xsl:element>
            <xsl:element name="caller_name">SYSTEM</xsl:element>
            <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
            <xsl:element name="author_name">
              <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
            </xsl:element>
            <xsl:element name="short_description">Add KWK Adjustment.</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;For AccountNumber: </xsl:text>
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
              <xsl:text>&#xA;Reason Code: </xsl:text>
              <xsl:value-of select="request-param[@name='REASON_CODE']"/>
              <xsl:text>&#xA;CanvassedCustomer: </xsl:text>
              <xsl:value-of select="request-param[@name='CANVASSED_CUSTOMER']"/>
              <xsl:text>&#xA;SplitBonus: </xsl:text>
              <xsl:value-of select="request-param[@name='SPLIT_BONUS']"/>
              <xsl:text>&#xA;InternalReasonText: </xsl:text>
              <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"/>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
              <xsl:element name="field_name">bonus_for_customer_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>               
          </xsl:element>
        </xsl:element>
        
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <!-- Get today's date -->
          <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
          <xsl:element name="command_id">create_kba_notification_2</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='START_DATE']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_adjustment_1</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Adjustment</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='START_DATE']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                  <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"
                    disable-output-escaping="yes"/>
                  <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
              <xsl:element name="field_name">bonus_for_customer_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>               
          </xsl:element>
        </xsl:element>
        
        <!-- Create Contact-->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact_3</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
              <xsl:element name="field_name">canvassed_customer</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">ADJUSTMENT</xsl:element>
            <xsl:element name="caller_name">SYSTEM</xsl:element>
            <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
            <xsl:element name="author_name">
              <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
            </xsl:element>
            <xsl:element name="short_description">Add KWK Adjustment (Split).</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;From AccountNumber: </xsl:text>
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
              <xsl:text>&#xA;Reason Code: </xsl:text>
              <xsl:value-of select="request-param[@name='REASON_CODE']"/>
              <xsl:text>&#xA;SplitBonus: </xsl:text>
              <xsl:value-of select="request-param[@name='SPLIT_BONUS']"/>
              <xsl:text>&#xA;InternalReasonText: </xsl:text>
              <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"/>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
              <xsl:element name="field_name">bonus_for_canvassed_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>               
          </xsl:element>
        </xsl:element>
        
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <!-- Get today's date -->
          <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
          <xsl:element name="command_id">create_kba_notification_3</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='START_DATE']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_adjustment_1</xsl:element>
                  <xsl:element name="field_name">canvassed_customer</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Adjustment</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='START_DATE']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                  <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"
                    disable-output-escaping="yes"/>
                  <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">modify_canvassed_customer</xsl:element>
              <xsl:element name="field_name">bonus_for_canvassed_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>               
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
