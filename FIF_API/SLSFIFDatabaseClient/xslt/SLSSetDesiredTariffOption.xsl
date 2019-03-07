<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated relocation FIF request

  @author wlazlow
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <xsl:if
        test="(count(request-param-list[@name='OLD_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item) != 0) or
        (count(request-param-list[@name='NEW_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item) != 0)">
        <!-- Generate Base Command Id for add and terminate service -->
        <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
        <xsl:variable name="DesiredDate" select="request-param[@name='DESIRED_DATE']"/>

        <!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
        <xsl:if test="(request-param[@name='ACCESS_NUMBER'] != '') or (request-param[@name='SERVICE_TICKET_POSITION_ID'] != '') or (request-param[@name='SERVICE_SUBSCRIPTION_ID'] != '')">
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">                        
               <xsl:if test="(request-param[@name='ACCESS_NUMBER'] != '' ) and (request-param[@name='SERVICE_TICKET_POSITION_ID'] = '') and (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
                <xsl:element name="access_number">
                  <xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
                </xsl:element>
                <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
              </xsl:if>
              <xsl:if test="(request-param[@name='SERVICE_TICKET_POSITION_ID'] != '') and (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
                <xsl:element name="service_ticket_position_id">
                  <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                </xsl:element>
              </xsl:if>
              <xsl:element name="effective_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
              </xsl:element>
              <xsl:element name="contract_number">
                <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
              </xsl:element>
              <xsl:element name="technical_service_code">VOICE</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>

    

        <!-- Set the new desired tariff options -->
        <xsl:for-each select="request-param-list[@name='NEW_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
          <xsl:variable name="ServiceCode" select="request-param[@name='SERVICE_CODE']"/>
          <xsl:variable name="SubOrderId" select="request-param[@name='SUB_ORDER_ID']"/>
          <!-- Add new tariff option service -->
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="$ServiceCode"/>
              </xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_TARIF_OPT</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list"> </xsl:element>
              <xsl:element name="sub_order_id">
                <xsl:value-of select="$SubOrderId"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Add contributing items -->
          <xsl:element name="CcmFifAddModifyContributingItemCmd">
            <xsl:element name="CcmFifAddModifyContributingItemInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="$ServiceCode"/>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="contributing_item_list">
                <xsl:element name="CcmFifContributingItem">
                  <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
                  <xsl:element name="start_date">
                    <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>

        <!-- Terminate Old TariffOption Services -->
        <xsl:if test="count(request-param-list[@name='OLD_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item) != 0">
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_child_ss_1</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_TARIF_OPT</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:for-each select="request-param-list[@name='OLD_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">
                      <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>

        <!-- deactivate the old contributing items -->
        <xsl:for-each select="request-param-list[@name='OLD_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
          <xsl:element name="CcmFifAddModifyContributingItemCmd">
            <xsl:element name="CcmFifAddModifyContributingItemInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
              </xsl:element>
              <xsl:element name="contributing_item_list">
                <xsl:element name="CcmFifContributingItem">
                  <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
                  <xsl:element name="stop_date">
                    <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>

      

 

          <!-- find an open customer order for the main access service -->
          <xsl:element name="CcmFifFindCustomerOrderCmd">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="CcmFifFindCustomerOrderInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="reason_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">AEND</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="state_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">ASSIGNED</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">RELEASED</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="allow_children">N</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Create Customer Order for add and terminate discount Services -->
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
              </xsl:element>
              <xsl:element name="cust_order_description">Tarifoption-Änderung</xsl:element>
              <xsl:element name="provider_tracking_no">001</xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='NEW_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
                  <xsl:variable name="ServiceCode" select="request-param[@name='SERVICE_CODE']"/>
                  <xsl:element name="CcmFifCommandRefCont">
                    <xsl:element name="command_id">
                      <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                </xsl:for-each>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">term_child_ss_1</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Release stand alone Customer Order for add and terminate discount Services -->
          <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="CcmFifReleaseCustOrderInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
              </xsl:element>
              <xsl:element name="customer_order_ref">
                <xsl:element name="command_id">create_co_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Release dependent Customer Order for add and terminate discount Services -->
          <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="CcmFifReleaseCustOrderInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
              </xsl:element>
              <xsl:element name="customer_order_ref">
                <xsl:element name="command_id">create_co_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>
              <xsl:element name="parent_customer_order_id_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
   
      </xsl:if>
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">MODIFY_TARIF_OPT</xsl:element>
          <xsl:element name="short_description">Änderung Tarifoptionen</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='USER_NAME']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='ROLLENBEZEICHNUNG']"/>
            <xsl:text>&#xA;Added tariff option services : </xsl:text>
            <xsl:for-each select="request-param-list[@name='NEW_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
              <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:text>&#xA;Removed tariff option services : </xsl:text>
            <xsl:for-each select="request-param-list[@name='OLD_TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
              <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>

 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
