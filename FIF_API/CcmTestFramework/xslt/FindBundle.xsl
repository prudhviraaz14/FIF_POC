<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for allocating a cid

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
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">

      <xsl:variable name="customerNumber" >
        <xsl:value-of select="request-param[@name='customerNumber']"/>
      </xsl:variable>

      <xsl:variable name="isListEmpty" select="count(request-param-list[@name='serviceList']/request-param-list-item)"/>

      <!-- lock customer to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
            <xsl:value-of select="$customerNumber"/>
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:variable name="bundleId">
        <xsl:value-of select="request-param[@name='bundleId']"/>
      </xsl:variable>

      <xsl:if test="$bundleId != ''">
        <!-- look for an existing bundle for the service -->			
        <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle</xsl:element>
          <xsl:element name="CcmFifFindBundleInCont">
            <xsl:element name="bundle_id">
              <xsl:value-of select="$bundleId"/>
            </xsl:element>            
            <xsl:element name="effective_status">ACTIVE</xsl:element>
            <xsl:element name="bundle_role_default_only">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
        
      <xsl:for-each select="request-param-list[@name='serviceList']/request-param-list-item">
        <!-- look for an existing bundle for the service -->			
        <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle</xsl:element>
          <xsl:element name="CcmFifFindBundleInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="$customerNumber"/>
            </xsl:element>            
            <xsl:element name="supported_object_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
             <xsl:element name="bundle_role_default_only">Y</xsl:element>
            <xsl:if test="position() > 1 or $bundleId != ''">
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_bundle</xsl:element>
                <xsl:element name="field_name">bundle_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>

      <!-- if no bundle was found for any of the services, 
        look for bundles created by the order position or -->			
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="$customerNumber"/>
          </xsl:element>            
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="order_id">
            <xsl:value-of select="request-param[@name='orderId']"/>
          </xsl:element>
          <xsl:element name="order_position_number">
            <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
          </xsl:element>
          <xsl:element name="empty_bundle_indicator">Y</xsl:element>
          <xsl:element name="allow_multiple_bundles">Y</xsl:element>
          <xsl:element name="effective_status">ACTIVE</xsl:element>
          <xsl:element name="exclude_other_orders">N</xsl:element>
          <xsl:element name="bundle_role_default_only">Y</xsl:element>
          <xsl:if test="$isListEmpty > 0 or $bundleId != ''">
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>      
      
      <!-- check for empty bundle, if nothing was found yet -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="$customerNumber"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="order_id">
            <xsl:value-of select="request-param[@name='orderId']"/>
          </xsl:element>
          <xsl:element name="order_position_number">
            <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
          </xsl:element>
          <xsl:element name="empty_bundle_indicator">Y</xsl:element>
          <xsl:element name="allow_multiple_bundles">Y</xsl:element>
          <xsl:element name="effective_status">ACTIVE</xsl:element>
          <xsl:element name="exclude_other_orders">Y</xsl:element>
          <xsl:element name="bundle_role_default_only">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>      
            
      <xsl:element name="CcmFifModifyBundleCmd">
        <xsl:element name="command_id">set_ao_indicator</xsl:element>
        <xsl:element name="CcmFifModifyBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>                  
          </xsl:element>
          <xsl:element name="ao_status">
            <xsl:value-of select="request-param[@name='amdocsOrderingIndicator']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create a new bundle if no one has been found -->
      <xsl:if test="request-param[@name='createBundle'] = 'Y'">
        <xsl:element name="CcmFifModifyBundleCmd">
          <xsl:element name="command_id">create_bundle</xsl:element>
          <xsl:element name="CcmFifModifyBundleInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="$customerNumber"/>
            </xsl:element>
            <xsl:element name="ao_status">
              <xsl:value-of select="request-param[@name='amdocsOrderingIndicator']"/>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>

        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_notification</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="dateutils:getCurrentDate()"/>
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
                  <xsl:text>BUNDLE_ID</xsl:text>
                </xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_bundle</xsl:element>
                  <xsl:element name="field_name">bundle_id</xsl:element>                  
                </xsl:element>
              </xsl:element>	              
            </xsl:element>         
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>  
      </xsl:if>
      
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_notification</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
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
                <xsl:text>BUNDLE_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_bundle</xsl:element>
                <xsl:element name="field_name">bundle_id</xsl:element>                  
              </xsl:element>
            </xsl:element>	              
          </xsl:element>          
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>  
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">bundleId</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_bundle</xsl:element>
              <xsl:element name="field_name">bundle_id</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">create_bundle</xsl:element>
              <xsl:element name="field_name">bundle_id</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
        <xsl:element name="CcmFifChangeExternalOrderCmd">
          <xsl:element name="command_id">change_external_order</xsl:element>
          <xsl:element name="CcmFifChangeExternalOrderInCont">
            <xsl:element name="order_id">
              <xsl:value-of select="request-param[@name='orderId']"/>
            </xsl:element>
            <xsl:element name="order_position_number">
              <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
            </xsl:element>
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>            
            <xsl:element name="customer_intention">
              <xsl:value-of select="request-param[@name='customerIntention']"/>
            </xsl:element>            
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>            
            <xsl:element name="state_rd">
              <xsl:value-of select="request-param[@name='externalOrderStatus']"/>
            </xsl:element>
            <xsl:element name="order_position_type">
              <xsl:value-of select="request-param[@name='orderPositionType']"/>
            </xsl:element>
            <xsl:element name="barcode">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>            
            <xsl:element name="workflow_type_rd">
              <xsl:value-of select="request-param[@name='workflowType']"/>
            </xsl:element>
            <xsl:element name="bundle_id_ref">
              <xsl:element name="command_id">bundleId</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>                  
            </xsl:element>
          </xsl:element>
        </xsl:element>      
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
