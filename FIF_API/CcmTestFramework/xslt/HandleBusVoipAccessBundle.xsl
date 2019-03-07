<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for handling of the BusVoip Access Bundles.
  @author lejam
-->
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

      <xsl:element name="Command_List">

         <!-- Calculate today -->
         <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
         <!-- Calculate tomorrow -->      
         <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
 
         <!-- get busvoip service by serv subs id -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_busvoip_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="service_subscription_id">
                   <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
               </xsl:element>
               <!--<xsl:element name="no_service_error">Y</xsl:element>-->
            </xsl:element>
         </xsl:element>

         <!-- get reference order  service of the busvoip -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_ref_order_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="product_subscription_id_ref">
                  <xsl:element name="command_id">find_busvoip_service</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="service_code">VI081</xsl:element>
               <!--<xsl:element name="no_service_error">Y</xsl:element>-->
               <xsl:element name="process_ind_ref">
                 <xsl:element name="command_id">find_busvoip_service</xsl:element>
                 <xsl:element name="field_name">service_found</xsl:element>
               </xsl:element>
               <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- reverse fixed ip address -->
         <xsl:variable name="fixedIPAddress">
           <xsl:value-of select="request-param[@name='fixedIPAddress']"/>
         </xsl:variable>
         <xsl:variable name="ip_number">
            <xsl:choose>
               <xsl:when test="contains($fixedIPAddress, ';')">
                  <xsl:value-of select="substring-after(substring-after($fixedIPAddress, ';'), ';')"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="$fixedIPAddress"/>
              </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="subnet_mask">
           <xsl:value-of select="substring-before(substring-after($fixedIPAddress, ';'), ';')"/>
         </xsl:variable>
         <xsl:variable name="alias">
           <xsl:value-of select="substring-before($fixedIPAddress, ';')"/>
         </xsl:variable>
         <xsl:variable name="fixedIPAddressReversed">
           <xsl:value-of select="concat($ip_number,';',$subnet_mask,';',$alias)"/>
         </xsl:variable>

         <!-- get service by fixed ip address -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_access_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="access_number">
                   <xsl:value-of select="$fixedIPAddressReversed"/>
               </xsl:element>
               <xsl:element name="access_number_type">IP_NET_ADDRESS</xsl:element>
               <xsl:element name="no_service_error">N</xsl:element>
               <xsl:element name="excluded_service_code_list">
                  <xsl:element name="CcmFifPassingValueCont">
                     <xsl:element name="value">VI081</xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <!-- get parent service (access) of fixed ip address -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_access_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="product_subscription_id_ref">
                  <xsl:element name="command_id">find_access_service</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
               <xsl:element name="no_service_error">N</xsl:element>
               <xsl:element name="process_ind_ref">
                 <xsl:element name="command_id">find_access_service</xsl:element>
                 <xsl:element name="field_name">service_found</xsl:element>
               </xsl:element>
               <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Create KBA notification -->
         <xsl:element name="CcmFifCreateExternalNotificationCmd">
           <xsl:element name="command_id">create_ext_notification_1</xsl:element>
           <xsl:element name="CcmFifCreateExternalNotificationInCont">
             <xsl:element name="notification_action_name">createKBANotification</xsl:element>
             <xsl:element name="target_system">KBA</xsl:element>
             <xsl:element name="parameter_value_list">
               <xsl:element name="CcmFifParameterValueCont">                            
                   <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                   <xsl:element name="parameter_value_ref">
                       <xsl:element name="command_id">find_busvoip_service</xsl:element>
                       <xsl:element name="field_name">customer_number</xsl:element>
                   </xsl:element>        
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">                            
                 <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
                   <xsl:element name="parameter_value_ref">
                     <xsl:element name="command_id">find_busvoip_service</xsl:element>
                     <xsl:element name="field_name">account_number</xsl:element>              
                   </xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">TYPE</xsl:element>
                 <xsl:element name="parameter_value">PROCESS</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">CATEGORY</xsl:element>
                 <xsl:element name="parameter_value">BVoIPBundleNotFound</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">USER_NAME</xsl:element>
                 <xsl:element name="parameter_value">
                   <xsl:value-of select="request-param[@name='clientName']"/>
                 </xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">TEXT</xsl:element>
                 <xsl:element name="parameter_value">                                 
                   <xsl:text>Aktivierung / Dienstleisterclearing / BVoIP - Access Product (FixedIPAddress:</xsl:text>
                   <xsl:value-of select="request-param[@name='fixedIPAddress']"/>
                   <xsl:text>, BusVoipId:</xsl:text>
                   <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                   <xsl:text>) für Bundle nicht gefunden</xsl:text>
                 </xsl:element>
               </xsl:element>
             </xsl:element>   
             <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">find_access_service</xsl:element>
               <xsl:element name="field_name">service_found</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">N</xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- find bundle -->
         <xsl:element name="CcmFifFindBundleCmd">
            <xsl:element name="command_id">find_bundle_access</xsl:element>
            <xsl:element name="CcmFifFindBundleInCont">
               <xsl:element name="bundle_type_rd">BUSVOIP_ACCESS</xsl:element>
               <xsl:element name="bundle_item_type_rd">BUSVOIP_ACCESS</xsl:element>
               <xsl:element name="supported_object_id_ref">
                  <xsl:element name="command_id">find_access_service</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
            </xsl:element>
         </xsl:element>
         <!-- check if this bundle has no busvoip -->
         <xsl:element name="CcmFifFindBundleCmd">
            <xsl:element name="command_id">find_bundle_access_empty</xsl:element>
            <xsl:element name="CcmFifFindBundleInCont">
               <xsl:element name="bundle_id_ref">
                  <xsl:element name="command_id">find_bundle_access</xsl:element>
                  <xsl:element name="field_name">bundle_id</xsl:element>
               </xsl:element>
               <xsl:element name="bundle_type_rd">BUSVOIP_ACCESS</xsl:element>
               <xsl:element name="bundle_item_type_rd">BUSVOIP_ACCSER</xsl:element>
               <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
            </xsl:element>
         </xsl:element>
         
         <!-- map conditions -->
         <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">map_access_bundle_empty</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
               <xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_bundle_access</xsl:element>
                        <xsl:element name="field_name">bundle_found</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">;</xsl:element>                     
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                         <xsl:element name="command_id">find_bundle_access_empty</xsl:element>
                         <xsl:element name="field_name">bundle_found</xsl:element>             
                     </xsl:element>
                  </xsl:element>
               <xsl:element name="output_string_type">[Y,N]</xsl:element>
               <xsl:element name="string_mapping_list">
                  <xsl:element name="CcmFifStringMappingCont">
                     <xsl:element name="input_string">Y;Y</xsl:element>
                     <xsl:element name="output_string">Y</xsl:element>                        
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
               <xsl:element name="no_mapping_error">N</xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Create KBA notification -->
         <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">concat_string_ext_not_2</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
               <xsl:element name="input_string_list">
                  <xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
                        <xsl:text>Aktivierung / Dienstleisterclearing / BVoIP - Access Product (FixedIPAddress:</xsl:text>
                        <xsl:value-of select="request-param[@name='fixedIPAddress']"/>
                        <xsl:text>, BusVoipId:</xsl:text>
                        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                        <xsl:text>) bereits in Bundle (BundelId:</xsl:text>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">find_bundle_access</xsl:element>
                     <xsl:element name="field_name">bundle_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifPassingValueCont">
                     <xsl:element name="value">
                        <xsl:text>).</xsl:text>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <xsl:element name="CcmFifCreateExternalNotificationCmd">
           <xsl:element name="command_id">create_ext_notification_2</xsl:element>
           <xsl:element name="CcmFifCreateExternalNotificationInCont">
             <xsl:element name="notification_action_name">createKBANotification</xsl:element>
             <xsl:element name="target_system">KBA</xsl:element>
             <xsl:element name="parameter_value_list">
               <xsl:element name="CcmFifParameterValueCont">                            
                   <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                   <xsl:element name="parameter_value_ref">
                       <xsl:element name="command_id">find_busvoip_service</xsl:element>
                       <xsl:element name="field_name">customer_number</xsl:element>
                   </xsl:element>        
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">                            
                 <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
                   <xsl:element name="parameter_value_ref">
                     <xsl:element name="command_id">find_busvoip_service</xsl:element>
                     <xsl:element name="field_name">account_number</xsl:element>              
                   </xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">TYPE</xsl:element>
                 <xsl:element name="parameter_value">PROCESS</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">CATEGORY</xsl:element>
                 <xsl:element name="parameter_value">BVoIPBundleAlreadyExists</xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">USER_NAME</xsl:element>
                 <xsl:element name="parameter_value">
                   <xsl:value-of select="request-param[@name='clientName']"/>
                 </xsl:element>
               </xsl:element>
               <xsl:element name="CcmFifParameterValueCont">
                 <xsl:element name="parameter_name">TEXT</xsl:element>
                   <xsl:element name="parameter_value_ref">
                     <xsl:element name="command_id">concat_string_ext_not_2</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>              
                   </xsl:element>
                </xsl:element>
             </xsl:element>   
             <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">map_access_bundle_empty</xsl:element>
                  <xsl:element name="field_name">output_string</xsl:element>                     
             </xsl:element>
             <xsl:element name="required_process_ind">Y</xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- find bundle -->
         <xsl:element name="CcmFifFindBundleCmd">
            <xsl:element name="command_id">find_bundle_busvoip</xsl:element>
            <xsl:element name="CcmFifFindBundleInCont">
               <xsl:element name="bundle_type_rd">BUSVOIP_ACCESS</xsl:element>
               <xsl:element name="bundle_item_type_rd">BUSVOIP_ACCSER</xsl:element>
               <xsl:element name="supported_object_id_ref">
                  <xsl:element name="command_id">find_busvoip_service</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
            </xsl:element>
         </xsl:element>


         <!-- map conditions -->
         <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">map_handle_busvoip_access_bundle</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
               <xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
                  <xsl:element name="input_string_list">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">find_access_service</xsl:element>
                        <xsl:element name="field_name">service_found</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="value">;</xsl:element>                     
                     </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                         <xsl:element name="command_id">map_access_bundle_empty</xsl:element>
                         <xsl:element name="field_name">output_string</xsl:element>             
                     </xsl:element>
                  </xsl:element>
               <xsl:element name="output_string_type">[Y,N]</xsl:element>
               <xsl:element name="string_mapping_list">
                  <xsl:element name="CcmFifStringMappingCont">
                     <xsl:element name="input_string">Y;N</xsl:element>
                     <xsl:element name="output_string">Y</xsl:element>                        
                  </xsl:element>
               </xsl:element>
               <xsl:element name="no_mapping_error">N</xsl:element>
            </xsl:element>
         </xsl:element>
         
         <!-- create bundle, if none is found --> 
         <xsl:element name="CcmFifHandleBusVoipAccessBundleCmd">
            <xsl:element name="command_id">handle_busvoip_bundle</xsl:element>
            <xsl:element name="CcmFifHandleBusVoipAccessBundleInCont">
               <xsl:element name="busvoip_service_sub_id_ref">
                  <xsl:element name="command_id">find_busvoip_service</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="busvoip_bundle_id_ref">
                  <xsl:element name="command_id">find_bundle_busvoip</xsl:element>
                  <xsl:element name="field_name">bundle_id</xsl:element>
               </xsl:element>
               <xsl:element name="access_service_sub_id_ref">
                  <xsl:element name="command_id">find_access_service</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="access_bundle_id_ref">
                  <xsl:element name="command_id">find_bundle_access</xsl:element>
                  <xsl:element name="field_name">bundle_id</xsl:element>
               </xsl:element>
               <xsl:element name="process_ind_ref">
                 <xsl:element name="command_id">map_handle_busvoip_access_bundle</xsl:element>
                 <xsl:element name="field_name">output_string</xsl:element>             
               </xsl:element>
               <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
         </xsl:element>
         
         <!-- create contact for the transaction -->        
         <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">concat_contact_string</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
               <xsl:element name="input_string_list">
                  <xsl:element name="CcmFifPassingValueCont">
                     <xsl:element name="value">
                        <xsl:text>Handle BusVoip Access Bundle</xsl:text>
                        <xsl:text>&#xA;- Bündle ID: </xsl:text>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">handle_busvoip_bundle</xsl:element>
                     <xsl:element name="field_name">bundle_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifPassingValueCont">
                     <xsl:element name="value">
                        <xsl:text>&#xA;TransactionID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="request-param[@name='clientName']"/>
                        <xsl:text>)</xsl:text>
                     </xsl:element>
                  </xsl:element>         
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="CcmFifCreateContactInCont">
               <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_busvoip_service</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>          
               </xsl:element>
               <xsl:element name="contact_type_rd">BUSVOIP_BUNDLE</xsl:element>
               <xsl:element name="short_description">Handle BusVoip Access Bundle</xsl:element>
               <xsl:element name="description_text_list">
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">concat_contact_string</xsl:element>
                     <xsl:element name="field_name">output_string</xsl:element>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="process_ind_ref">
                 <xsl:element name="command_id">map_handle_busvoip_access_bundle</xsl:element>
                 <xsl:element name="field_name">output_string</xsl:element>             
               </xsl:element>
               <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
         </xsl:element>

      </xsl:element>
   </xsl:template>
</xsl:stylesheet>

