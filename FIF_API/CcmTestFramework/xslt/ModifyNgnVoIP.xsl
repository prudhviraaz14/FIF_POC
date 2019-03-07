<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a FIF request for Modify NGN VoIP 
	@author Pranjali
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
		<!-- Copy over transaction ID,action name -->
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
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
		
		<xsl:element name="Command_List">
		  
			<!--Get Customer Number if not provided-->
			<xsl:if test="(request-param[@name='customerNumber'] = '')">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_1</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!--Get Account Number if not provided-->
			<xsl:if test="(request-param[@name='accountNumber'] = '')">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_2</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
          <!--Get Contract number from CCM_EXTERNAL_NOTIFICATION if not provided-->
		  <xsl:if test="(request-param[@name='contractNumber'] = '')">
            <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_external_notification_3</xsl:element>
                <xsl:element name="CcmFifReadExternalNotificationInCont">
			      <xsl:element name="transaction_id">
			      	<xsl:value-of select="request-param[@name='requestListId']"/>
			      </xsl:element>                      
			    <xsl:element name="parameter_name">CONTRACT_NUMBER</xsl:element>
		      </xsl:element>
            </xsl:element> 
          </xsl:if>	
           
          <!-- Find Service Subscription by access number or Service Subscription Id-->
		  <xsl:if test="(request-param[@name='accessNumber'] != '') or (request-param[@name='serviceSubscriptionId'] != '')">
			<xsl:element name="CcmFifFindServiceSubsCmd">
			  <xsl:element name="command_id">find_service_1</xsl:element>
			  <xsl:element name="CcmFifFindServiceSubsInCont">
			    <!-- If only access number is provided-->
				<xsl:if test="((request-param[@name='accessNumber'] != '' )and (request-param[@name='serviceSubscriptionId'] = ''))">
				  <xsl:element name="access_number">
					<xsl:value-of select="request-param[@name='accessNumber']"/>
			      </xsl:element>
				  <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
				</xsl:if>
				<!-- If only service subscription Id  is provided-->
				<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
				  <xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				  </xsl:element>
				</xsl:if>
			  	
			  	<xsl:if test="request-param[@name='customerNumber']!=''">
			  		<xsl:element name="customer_number">
			  			<xsl:value-of select="request-param[@name='customerNumber']"/>
			  		</xsl:element>
			  	</xsl:if>			  	
			  	<xsl:if test="request-param[@name='contractNumber']!=''">
			  		<xsl:element name="contract_number">
			  			<xsl:value-of select="request-param[@name='contractNumber']"/>
			  		</xsl:element>
			  	</xsl:if>				
			  </xsl:element>
			</xsl:element>
		  </xsl:if>		  
          <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber and serviceSubscriptionId not provided -->
		  <xsl:if test="(request-param[@name='accessNumber'] = '') and  (request-param[@name='serviceSubscriptionId'] = '')">
			<!-- Get Service Subscription ID -->
			<xsl:element name="CcmFifReadExternalNotificationCmd">
			  <xsl:element name="command_id">read_external_notification_4</xsl:element>
			  <xsl:element name="CcmFifReadExternalNotificationInCont">
				<xsl:element name="transaction_id">
					<xsl:value-of select="request-param[@name='requestListId']"/>
				</xsl:element>
				<xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
			  </xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsCmd">
			  <xsl:element name="command_id">find_service_1</xsl:element>
			  <xsl:element name="CcmFifFindServiceSubsInCont">
			 	<xsl:element name="service_subscription_id_ref">
				  <xsl:element name="command_id">read_external_notification_4</xsl:element>
				  <xsl:element name="field_name">parameter_value</xsl:element>
				</xsl:element>    
						
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
               	<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
              
                <xsl:element name="service_characteristic_list">
                  <!-- Grund der Neukonfiguration -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">VI008</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                  
                  	
                  	<xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>  
            </xsl:element>  
			
            <!-- Add Feature  Service S0106 Service Level Classic   if serviceLevelClassic=ADD -->
            <xsl:if test="request-param[@name='serviceLevel'] = 'ADD'">
              <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_1</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
			      <xsl:element name="product_subscription_ref">
			        <xsl:element name="command_id">find_service_1</xsl:element>
  			        <xsl:element name="field_name">product_subscription_id</xsl:element>
			      </xsl:element> 
			      <xsl:element name="service_code">S0106</xsl:element>
			      <xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
			      <xsl:element name="desired_date">
			        <xsl:value-of select="request-param[@name='desiredDate']"/>
			      </xsl:element>
			      <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		        	
		        	<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
	              <xsl:if test="request-param[@name='accountNumber']=''">
					  <xsl:element name="account_number_ref">
					    <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					  </xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
					  <xsl:element name="account_number">
					    <xsl:value-of select="request-param[@name='accountNumber']"/>
					  </xsl:element>
				    </xsl:if>
			      <xsl:element name="service_characteristic_list">
			        
			      </xsl:element>
		        </xsl:element>
		      </xsl:element>
            </xsl:if> 
            <!-- Add Feature  Service V0099 Bonus My Company  if bonusMyCompany is set -->
			<xsl:if test="request-param[@name='bonusMyCompany'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_2</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
					    <xsl:element name="product_subscription_ref">
			        <xsl:element name="command_id">find_service_1</xsl:element>
  			        <xsl:element name="field_name">product_subscription_id</xsl:element>
			      </xsl:element> 
						
						<xsl:element name="service_code">V0099</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
                        <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<!-- Bemerkung -->
						<xsl:element name="service_characteristic_list">
							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0025 Block International   if blockInternational  is set to ADD -->
  	        <xsl:if test="request-param[@name='blockInternational'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_3</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
			          <xsl:element name="command_id">find_service_1</xsl:element>
  			          <xsl:element name="field_name">product_subscription_id</xsl:element>
			        </xsl:element> 
						<xsl:element name="service_code">V0025</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
			            <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0026 Block Outside EU if blockOutsideEU  is set -->
			<xsl:if test="request-param[@name='blockOutsideEu'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_4</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
			          <xsl:element name="command_id">find_service_1</xsl:element>
  			          <xsl:element name="field_name">product_subscription_id</xsl:element>
			        </xsl:element> 
						<xsl:element name="service_code">V0026</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						    <xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
						<xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<!-- Bemerkung -->
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0027 Block 0190/0900 if  block0190/0900  is set -->
			<xsl:if test="request-param[@name='block0190/0900'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_5</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
			          <xsl:element name="command_id">find_service_1</xsl:element>
  			          <xsl:element name="field_name">product_subscription_id</xsl:element>
			        </xsl:element> 
						<xsl:element name="service_code">V0027</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
				
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
						<xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0260 Sperre 0900  if block0900  is set -->
			<xsl:if test="request-param[@name='block0900'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_16</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
						<xsl:element name="service_code">V0260</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
						
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
						<xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<xsl:element name="service_characteristic_list">
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			
			
			<!-- Add Feature  Service V0254 Sperre 0137   if block0137calls=ADD -->
            <xsl:if test="request-param[@name='block0137Calls'] = 'ADD'">
              <xsl:element name="CcmFifAddServiceSubsCmd">
		       <xsl:element name="command_id">add_service_10</xsl:element>
		       <xsl:element name="CcmFifAddServiceSubsInCont">
			     <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
			     <xsl:element name="service_code">V0254</xsl:element>
			     <xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
			     <xsl:element name="desired_date">
			       <xsl:value-of select="request-param[@name='desiredDate']"/>
			     </xsl:element>
			     <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
		       
		       	<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
	             <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>		  
			     <xsl:element name="service_characteristic_list">
			       
			     </xsl:element>
		        </xsl:element>
		     </xsl:element>        
            </xsl:if>
            <!-- Add Feature  Service V0255 Sperre 01805 Calls   if block01805calls =ADD  -->
            <xsl:if test="request-param[@name='block01805Calls'] = 'ADD'">
              <xsl:element name="CcmFifAddServiceSubsCmd">
		       <xsl:element name="command_id">add_service_11</xsl:element>
		       <xsl:element name="CcmFifAddServiceSubsInCont">
			     <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
			     <xsl:element name="service_code">V0255</xsl:element>
			     <xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
			     <xsl:element name="desired_date">
			       <xsl:value-of select="request-param[@name='desiredDate']"/>
			     </xsl:element>
			     <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
		       	
		       	<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
			     <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
			     <xsl:element name="service_characteristic_list">
			       
			     </xsl:element>
		       </xsl:element>
		     </xsl:element>        
            </xsl:if>  
            
            <!-- Add Feature  Service V0256 Sperre  Premium  if blockPremium =ADD -->
            <xsl:if test="request-param[@name='blockPremiumCalls'] = 'ADD'">            
              <xsl:element name="CcmFifAddServiceSubsCmd">
		       <xsl:element name="command_id">add_service_12</xsl:element>
		       <xsl:element name="CcmFifAddServiceSubsInCont">
			     <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
			     <xsl:element name="service_code">V0256</xsl:element>
			     <xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
			     <xsl:element name="desired_date">
			       <xsl:value-of select="request-param[@name='desiredDate']"/>
			     </xsl:element>
			     <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
		      
		       	<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
	             <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>		 
			     <xsl:element name="service_characteristic_list">
			       
			     </xsl:element>
		       </xsl:element>
		     </xsl:element>        
            </xsl:if>   
            <!-- Add Feature  Service V0257 Sperre abgehender Verkehr  if blockOutgoingTraffic =ADD  -->
            <xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'ADD'">
              <xsl:element name="CcmFifAddServiceSubsCmd">
		       <xsl:element name="command_id">add_service_13</xsl:element>
		       <xsl:element name="CcmFifAddServiceSubsInCont">
			     <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
			     <xsl:element name="service_code">V0257</xsl:element>
			     <xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
			     <xsl:element name="desired_date">
			       <xsl:value-of select="request-param[@name='desiredDate']"/>
			     </xsl:element>
			     <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
		       	
		       	<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
		         <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
			     <xsl:element name="service_characteristic_list">
			       
			     </xsl:element>
		       </xsl:element>
		     </xsl:element>        
            </xsl:if>  
            <!-- Add Feature  Service V0258 Sperre abgehender Verkehr(Ausname Ortsgesprache,0800,011xy)  if blockOutgoingTrafficExceptLocal  is set -->
			<xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_14</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
                     <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
						<xsl:element name="service_code">V0258</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
						
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
			            <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<xsl:element name="service_characteristic_list">
							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>  
			<!-- Add Feature  Service V0259 Sperre MobilFunk  if blockMobileNumbers  is set -->
			<xsl:if test="request-param[@name='blockMobileNumbers'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_15</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
                         <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element> 
   						<xsl:element name="service_code">V0259</xsl:element>
   						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
		                <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<xsl:element name="service_characteristic_list">
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>  
			<!-- Add Feature  Service V0261 Sperre 118xy  if block118xy  is set -->
			<xsl:if test="request-param[@name='block118xy'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_17</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
                        <xsl:element name="product_subscription_ref">
			              <xsl:element name="command_id">find_service_1</xsl:element>
  			              <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element>  
						<xsl:element name="service_code">V0261</xsl:element>
						<xsl:element name="parent_service_subs_ref">
		              <xsl:element name="command_id">find_service_1</xsl:element>			
		              <xsl:element name="field_name">service_subscription_id</xsl:element> 
					</xsl:element>   
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
						
						<xsl:element name="reason_rd">CREATENGNVOIP</xsl:element>
	                    <xsl:if test="request-param[@name='accountNumber']=''">
					      <xsl:element name="account_number_ref">
					        <xsl:element name="command_id">read_external_notification_2 </xsl:element>
						    <xsl:element name="field_name">parameter_value</xsl:element>
					     </xsl:element>
					    </xsl:if>
					    <xsl:if test="request-param[@name='accountNumber']!=''">
					      <xsl:element name="account_number">
					        <xsl:value-of select="request-param[@name='accountNumber']"/>
					      </xsl:element>
				        </xsl:if>
						<xsl:element name="service_characteristic_list">
							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>  
			
		
			<!-- Remove  Feature  Service  Service Level Classic serviceLevelClassic  = REMOVE -->
            <xsl:if test="request-param[@name='serviceLevel'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_1</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	            <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">S0106</xsl:element>      	      	      
      	      	      </xsl:element>      	      	    
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>  
            <!-- Remove  Feature  Service  Bonus My Company if bonusMyCompany  = REMOVE -->
            <xsl:if test="request-param[@name='bonusMyCompany'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_2</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0099</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>
            <!-- Remove  Feature  Service  Block International  if blockInternational  = REMOVE -->
            <xsl:if test="request-param[@name='blockInternational'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_3</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0025</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>         
            <!-- Remove  Feature  Service  BlockOutsideEU  if blockOutsideEu  = REMOVE -->
            <xsl:if test="request-param[@name='blockOutsideEu'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_4</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0026</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>          
            
            <!-- Remove  Feature  Service  Block0190/0900  if block0190/0900  = REMOVE -->
            <xsl:if test="request-param[@name='block0190/0900'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_5</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0027</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>     
                           
                                
               
            <!-- Remove  Feature  Service Block0137 Calls   if block0137Calls  = REMOVE -->
            <xsl:if test="request-param[@name='block0137Calls'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_10</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0254</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>               
            <!-- Remove  Feature  Service Block01805 Calls   if block01805Calls  = REMOVE -->
            <xsl:if test="request-param[@name='block01805Calls'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_11</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0255</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element> 
            </xsl:if>               
            <!-- Remove  Feature  Service Block Premium    if blockPremium  = REMOVE -->
            <xsl:if test="request-param[@name='blockPremiumCalls'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_12</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0256</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element>       	      
            </xsl:if>              
            <!-- Remove  Feature  Service Block Outgoing Traffic    if blockOutgoingTraffic  = REMOVE -->
            <xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_13</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0257</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element>       	      
            </xsl:if>    
            <!-- Remove  Feature  Service Block Outgoing Traffic Except Local   if blockOutgoingTrafficExceptLocal  = REMOVE -->
            <xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_14</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0258</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element>       	      
            </xsl:if>                        
            <!-- Remove  Feature  Service Block Mobile Numbers  if blockMobileNumbers  = REMOVE -->
            <xsl:if test="request-param[@name='blockMobileNumbers'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_15</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0259</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element>       	      
            </xsl:if>              
            <!-- Remove  Feature  Service Block0900  if block0900  = REMOVE -->
            <xsl:if test="request-param[@name='block0900'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_16</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0260</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element>       	      
            </xsl:if>              
            <!-- Remove  Feature  Service Block118xy  if block118xy  = REMOVE -->
            <xsl:if test="request-param[@name='block118xy'] = 'REMOVE'">
              <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
      	        <xsl:element name="command_id">terminate_service_17</xsl:element>
      	        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
      	          <xsl:element name="service_subscription_ref">
      	      	    <xsl:element name="command_id">find_service_1</xsl:element>
      	      	    <xsl:element name="field_name">service_subscription_id</xsl:element>
      	          </xsl:element>
      	          <xsl:element name="no_child_error_ind">N</xsl:element>
      	          <xsl:element name="desired_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>	    	          
      	          </xsl:element>
      	          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
      	        	<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
      	        	
      	          <xsl:element name="service_code_list">
      	      	    <xsl:element name="CcmFifPassingValueCont">
      	      	      <xsl:element name="service_code">V0261</xsl:element>      	      	      
      	      	    </xsl:element>
      	          </xsl:element>
      	        </xsl:element>
      	      </xsl:element>       	      
            </xsl:if>       
            
     
            
                  
            <!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_2</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1 </xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='lanPathFileString']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='providerTrackingNumber']!=''">
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='providerTrackingNumber']=''">
						<xsl:element name="provider_tracking_no">001</xsl:element>	
					</xsl:if>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='scanDate']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='entryDate']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
					 <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">reconf_serv_1</xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                      </xsl:element>                       
                      <xsl:if test="request-param[@name='serviceLevel'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_1</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 				                              
                      <xsl:if test="request-param[@name='bonusMyCompany'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_2</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 				      
				      <xsl:if test="request-param[@name='blockInternational'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_3</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockOutsideEu'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_4</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block0190/0900'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_5</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if>  		   
					 
					   
					  <xsl:if test="request-param[@name='block0137Calls'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_10</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block01805Calls'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_11</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockPremiumCalls'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_12</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_13</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if>  
					  <xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_14</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockMobileNumbers'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_15</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block0900'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_16</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block118xy'] = 'ADD'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_17</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if>
						  
					  					  
					  					  
					</xsl:element> 
				</xsl:element>
			</xsl:element>
			
			
			<!--Release as stand alone customer order-->
			<xsl:if test="request-param[@name='requestListId'] = ''">  
			<xsl:element name="CcmFifReleaseCustOrderCmd">
			    <xsl:element name="command_id">release_co2</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_2</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>					
				</xsl:element>
			</xsl:element>
			</xsl:if>
			<!--Release as delayed customer order-->
			<xsl:if test="request-param[@name='requestListId'] != ''">  
			<xsl:element name="CcmFifReleaseCustOrderCmd">
			    <xsl:element name="command_id">release_co2_delayed</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_2</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>					
					<xsl:element name="release_delay_date">
							<xsl:value-of select="$tomorrow"/>	
					</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>
			<!-- Create Customer Order for  termination of services   -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_3</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1 </xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='lanPathFileString']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='providerTrackingNumber']!=''">
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='providerTrackingNumber']=''">
						<xsl:element name="provider_tracking_no">001</xsl:element>	
					</xsl:if>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='scanDate']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='entryDate']"/>
					</xsl:element>
					
					<xsl:element name="service_ticket_pos_list">
					  <xsl:if test="request-param[@name='serviceLevel'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_1</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 				                              
                      <xsl:if test="request-param[@name='bonusMyCompany'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_2</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 				      
				      <xsl:if test="request-param[@name='blockInternational'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_3</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockOutsideEu'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_4</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block0190/0900'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_5</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if>	   
					  <xsl:if test="request-param[@name='block0137Calls'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_10</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block01805Calls'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_11</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockPremiumCalls'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_12</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_13</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_14</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					    <xsl:if test="request-param[@name='blockMobileNumbers'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_15</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block0900'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_16</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block118xy'] = 'REMOVE'">        		
					    <xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">terminate_service_17</xsl:element>
						  <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						 </xsl:element>
					  </xsl:if>
					
					</xsl:element> 
				</xsl:element>
			</xsl:element>
			
			<!--Release  standalone customer order for termination  -->
			<xsl:if test="request-param[@name='requestListId'] = ''"> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_customer_order_3</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_3</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>
			<!--Release  delayed customer order for termination  -->
			<xsl:if test="request-param[@name='requestListId'] != ''"> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_co3_delayed</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_3</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="release_delay_date">
							<xsl:value-of select="$tomorrow"/>	
					</xsl:element>					
				</xsl:element>
			</xsl:element>
			</xsl:if>
			<!-- Create Contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
				<xsl:element name="contact_type_rd">VOIP_CONTRACT</xsl:element>
						<xsl:element name="short_description">
						<xsl:text>ModifyNgnVoIP contract</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;Modify NGN_VOIP Contract has been created on:</xsl:text>
						<xsl:value-of select="request-param[@name='desiredDate']"/>
									
					</xsl:element>
				</xsl:element>
			</xsl:element>		
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
