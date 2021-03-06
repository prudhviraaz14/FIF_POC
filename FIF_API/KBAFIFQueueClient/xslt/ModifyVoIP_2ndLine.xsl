<xsl:element name="CcmFifCommandList">
	<xsl:element name="transaction_id">
		<xsl:value-of select="request-param[@name='transactionID']"/>
	</xsl:element>
	<xsl:element name="client_name">
		<xsl:value-of select="request-param[@name='clientName']"/>
	</xsl:element>
	<xsl:variable name="TopAction" select="//request/action-name"/>
	<xsl:if test="$TopAction != 'modifyNgnVoIP'">
	   <xsl:element name="action_name">
		  <xsl:value-of select="concat($TopAction, '_2ndLine')"/>
	    </xsl:element>
	</xsl:if>
	<xsl:if test="$TopAction = 'modifyNgnVoIP'">
	    <xsl:variable name="TopAction1">modifyVoIP</xsl:variable>
	    <xsl:element name="action_name">
		  <xsl:value-of select="concat($TopAction1, '_2ndLine')"/>
	    </xsl:element>
	</xsl:if>
	<xsl:element name="override_system_date">
		<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
	</xsl:element>
	<!-- Calculate today and one day before the desired date -->
	<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
	<!-- Convert the termination date to OPM format -->
	<xsl:variable name="dateInOPMFormat"
		select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
	<xsl:element name="Command_List">

		<!-- IT16902 Validation - There should not be request for configuring feature services -->
		<!--                      access numbers together 									 -->
		<xsl:if test="((request-param[@name='serviceLevel'] != '') 
			or (request-param[@name='bonusMyCompany'] != '')
			or (request-param[@name='blockInternational'] != '')
			or (request-param[@name='blockOutsideEU'] != '')
			or (request-param[@name='block0190/0900'] != '')
			or (request-param[@name='block0900'] != '')
			or (request-param[@name='block0137Calls'] != '')
			or (request-param[@name='block01805Calls'] != '')
			or (request-param[@name='blockPremiumCalls'] != '')
			or (request-param[@name='blockOutgoingTraffic'] != '')
			or (request-param[@name='blockOutgoingTrafficExceptLocal'] != '')
			or (request-param[@name='blockMobileNumbers'] != '')
			or (request-param[@name='block118xy'] != ''))
			and ((request-param[@name='numberOfNewAccessNumbers'] != '')
			or (count(request-param-list[@name='newAccessNumberList']/request-param-list-item) != 0))">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">reconfigure_error_2</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Can not perform Reconfigure Feature Service and Add Additional Access Numbers in the same Transaction.</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>	
			
	          <!-- Find Service Subscription by access number or Service Subscription Id-->
		<xsl:if test="(request-param[@name='accessNumber'] != '') or (request-param[@name='serviceSubscriptionId'] != '') or (request-param[@name='serviceTicketPositionId'] != '') or (request-param[@name='productSubscriptionId'] != '')">
			<xsl:element name="CcmFifFindServiceSubsCmd">
			  <xsl:element name="command_id">find_service_1</xsl:element>
			  <xsl:element name="CcmFifFindServiceSubsInCont">
				<!-- If only service subscription Id  is provided-->
				<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
				  <xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				  </xsl:element>
				</xsl:if>
				<!-- If only service ticket position Id  is provided-->
				<xsl:if test="(request-param[@name='serviceTicketPositionId'] != '') and (request-param[@name='serviceSubscriptionId'] = '')">
					<xsl:element name="service_ticket_position_id">
						<xsl:value-of select="request-param[@name='serviceTicketPositionId']"/>
					</xsl:element>
				</xsl:if>
			    <!-- If only access number is provided-->
				<xsl:if test="((request-param[@name='accessNumber'] != '' )and (request-param[@name='serviceSubscriptionId'] = '') and (request-param[@name='serviceTicketPositionId'] = ''))">
				  <xsl:element name="access_number">
					<xsl:value-of select="request-param[@name='accessNumber']"/>
			      </xsl:element>
				  <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
				</xsl:if>
		  		<xsl:element name="customer_number">
		  			<xsl:value-of select="request-param[@name='customerNumber']"/>
		  		</xsl:element>		  	
			  	<xsl:if test="request-param[@name='contractNumber']!=''">
			  		<xsl:element name="contract_number">
			  			<xsl:value-of select="request-param[@name='contractNumber']"/>
			  		</xsl:element>
			  	</xsl:if>
				<xsl:if test="((request-param[@name='productSubscriptionId'] != '' ) and (request-param[@name='accessNumber'] = '') and (request-param[@name='serviceTicketPositionId'] = '')  and (request-param[@name='serviceSubscriptionId'] = ''))">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='productSubscriptionId']"/>
					</xsl:element>
				   	<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
				</xsl:if>			  					
			  </xsl:element>
			</xsl:element>
	  	</xsl:if>		  
       <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber and serviceSubscriptionId not provided -->
		<xsl:if test="(request-param[@name='accessNumber'] = '') and  (request-param[@name='serviceSubscriptionId'] = '') and (request-param[@name='serviceTicketPositionId'] = '') and (request-param[@name='productSubscriptionId'] = '')">
			<!-- Get Service Subscription ID -->
			<xsl:element name="CcmFifReadExternalNotificationCmd">
			  <xsl:element name="command_id">read_external_notification_1</xsl:element>
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
				  <xsl:element name="command_id">read_external_notification_1</xsl:element>
				  <xsl:element name="field_name">parameter_value</xsl:element>
				</xsl:element>    
			  </xsl:element>
			</xsl:element>
		</xsl:if>


	  	<xsl:if test="((request-param[@name='numberOfNewAccessNumbers'] != '')
	             or (count(request-param-list[@name='newAccessNumberList']/request-param-list-item) != 0))">
	  	
  		<!-- IT16902 Validate Number of Access Numbers-->
  		<xsl:element name="CcmFifValAccessNumbersCmd">
  			<xsl:element name="command_id">val_access_number_1</xsl:element>
  			<xsl:element name="CcmFifValAccessNumbersInCont">
  				<xsl:element name="service_subscription_ref">
  					<xsl:element name="command_id">find_service_1</xsl:element>
  					<xsl:element name="field_name">service_subscription_id</xsl:element>
  				</xsl:element>
  				<xsl:element name="ported_new_ans">
  					<xsl:for-each select="request-param-list[@name='newAccessNumberList']/request-param-list-item">
  						<xsl:element name="CcmFifPassingValueCont">
  							<xsl:element name="value">
  								<xsl:value-of select="request-param[@name='newAccessNumber']"/>
  							</xsl:element>
  						</xsl:element>
  					</xsl:for-each>
  				</xsl:element>
  				<xsl:element name="number_of_new_ans">
  					<xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
  				</xsl:element>
  			</xsl:element>
  		</xsl:element>	 
	  		
		<!-- Reconfigure Service Subscription : Access Numbers -->
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
	              	<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
	                <xsl:element name="service_characteristic_list">
	                	<!-- Bemerkung -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">V0008</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">Rufnummernänderung</xsl:element>
	                	</xsl:element>
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
	                	<!-- Aktivierungsdatum -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">V0909</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">
	                			<xsl:value-of select="$dateInOPMFormat"/>
	                		</xsl:element>
	                	</xsl:element>
	                	<!-- Number of new access numbers -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">V0936</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">
	                			<xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
	                		</xsl:element>
	                	</xsl:element>	                			
                		<!-- Reconfigure Access Number -->
			           	<xsl:for-each select="request-param-list[@name='newAccessNumberList']/request-param-list-item">
            	    		<xsl:variable name="NewAccessNumber" select="request-param[@name='newAccessNumber']"/>
            	    		<xsl:variable name="Count" select="position()"/>
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
									<xsl:value-of select="substring-before(request-param[@name='newAccessNumber'], ';')"/>
								</xsl:element>
								<xsl:element name="city_code">
									<xsl:value-of select="substring-before(substring-after(request-param[@name='newAccessNumber'],';'), ';')"/>
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="substring-after(substring-after(request-param[@name='newAccessNumber'],';'), ';')"/>
								</xsl:element>
							</xsl:element>
               			</xsl:for-each>
                	</xsl:element>
             	</xsl:element>
             </xsl:element>
		</xsl:if>
			
		<!-- Reconfigure Service Subscription : Feature Services-->
		<xsl:if test="((request-param[@name='serviceLevel'] != '') 
		               or (request-param[@name='bonusMyCompany'] != '')
		               or (request-param[@name='blockInternational'] != '')
		               or (request-param[@name='blockOutsideEU'] != '')
		               or (request-param[@name='block0190/0900'] != '')
		               or (request-param[@name='block0900'] != '')
		               or (request-param[@name='block0137Calls'] != '')
		               or (request-param[@name='block01805Calls'] != '')
		               or (request-param[@name='blockPremiumCalls'] != '')
		               or (request-param[@name='blockOutgoingTraffic'] != '')
		               or (request-param[@name='blockOutgoingTrafficExceptLocal'] != '')
		               or (request-param[@name='blockMobileNumbers'] != '')
		               or (request-param[@name='block118xy'] != ''))">
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
	              	<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
	                <xsl:element name="service_characteristic_list">
	                	<!-- Bemerkung -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">V0008</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">Rufnummernsperre-Änderung</xsl:element>
	                	</xsl:element>
	                	<!-- Grund der Konfiguration -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">VI008</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">Rufnummernsperre-Änderung</xsl:element>
	                	</xsl:element>
	                	<!-- Bearbeitungsart -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">VI002</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">OP</xsl:element>
	                	</xsl:element>
	                	<!-- Aktivierungsdatum -->
	                	<xsl:element name="CcmFifConfiguredValueCont">
	                		<xsl:element name="service_char_code">V0909</xsl:element>
	                		<xsl:element name="data_type">STRING</xsl:element>
	                		<xsl:element name="configured_value">
	                			<xsl:value-of select="$dateInOPMFormat"/>
	                		</xsl:element>
	                	</xsl:element>
	                	</xsl:element>
					</xsl:element>  
				</xsl:element>  
           		            	
	            	<!-- Add Feature  Service V0099 Bonus My Company  if bonusMyCompany is set -->
		<xsl:if test="request-param[@name='bonusMyCompany'] = 'ADD'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_1</xsl:element>
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
					<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
	                        			<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<!-- Bemerkung -->
					<xsl:element name="service_characteristic_list">
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">NOT_RELEVANT</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		<!-- Add Feature  Service V0025 Block International   if blockInternational  is set to ADD -->
  	        	<xsl:if test="request-param[@name='blockInternational'] = 'ADD'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_2</xsl:element>
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
					
						<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
			            			<xsl:if test="request-param[@name='accountNumber']=''">
						      	<xsl:element name="account_number_ref">
						      		<xsl:element name="command_id">find_service_1</xsl:element>
						      		<xsl:element name="field_name">account_number</xsl:element>
						      	</xsl:element>
					    	</xsl:if>
					    	<xsl:if test="request-param[@name='accountNumber']!=''">
						      	<xsl:element name="account_number">
						        		<xsl:value-of select="request-param[@name='accountNumber']"/>
						      	</xsl:element>
				        		</xsl:if>
						<xsl:element name="service_characteristic_list">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0008</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">NOT_RELEVANT</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0026 Block Outside EU if blockOutsideEU  is set -->
			<xsl:if test="request-param[@name='blockOutsideEU'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_3</xsl:element>
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
						<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							 <xsl:element name="account_number">
							 	<xsl:value-of select="request-param[@name='accountNumber']"/>
							 </xsl:element>
					        	</xsl:if>
						<!-- Bemerkung -->
						<xsl:element name="service_characteristic_list">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0008</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">NOT_RELEVANT</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature Service V0027 Block block0190/0900 is set -->
			<xsl:if test="request-param[@name='block0190/0900'] = 'ADD'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_4</xsl:element>
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
						<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
						<xsl:if test="request-param[@name='accountNumber']=''">
					      		<xsl:element name="account_number_ref">
					      			<xsl:element name="command_id">find_service_1</xsl:element>
					      			<xsl:element name="field_name">account_number</xsl:element>
					      		</xsl:element>
					    	</xsl:if>
					    	<xsl:if test="request-param[@name='accountNumber']!=''">
						      	<xsl:element name="account_number">
						        		<xsl:value-of select="request-param[@name='accountNumber']"/>
						      	</xsl:element>
				        		</xsl:if>
						<xsl:element name="service_characteristic_list">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0008</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">NOT_RELEVANT</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
            			<!-- Remove  Feature  Service  Bonus My Company if bonusMyCompany  = REMOVE -->
            			<xsl:if test="request-param[@name='bonusMyCompany'] = 'REMOVE'">
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
      	      	      					<xsl:element name="service_code">V0099</xsl:element>      	      	      
      	      	    				</xsl:element>
      	          				</xsl:element>
              				</xsl:element>
      	      		</xsl:element> 
            		</xsl:if>
            		<!-- Remove  Feature  Service  Block International  if blockInternational  = REMOVE -->
            		<xsl:if test="request-param[@name='blockInternational'] = 'REMOVE'">
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
		      	      	      			<xsl:element name="service_code">V0025</xsl:element>      	      	      
		      	      	    		</xsl:element>
	      	          			</xsl:element>
      	        			</xsl:element>
      	      		</xsl:element> 
            		</xsl:if>
            		<!-- Remove  Feature  Service  BlockOutsideEU  if blockOutsideEU  = REMOVE -->
		<xsl:if test="request-param[@name='blockOutsideEU'] = 'REMOVE'">
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
      	      	      					<xsl:element name="service_code">V0026</xsl:element>      	      	      
      	      	    				</xsl:element>
      	          				</xsl:element>
              				</xsl:element>
              			</xsl:element> 
		</xsl:if>          
            		<!-- Remove  Feature  Service  Block0190/0900  if block0190/0900  = REMOVE -->
            		<xsl:if test="request-param[@name='block0190/0900'] = 'REMOVE'">
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
      	      	      					<xsl:element name="service_code">V0027</xsl:element>      	      	      
      	      	    				</xsl:element>
      	          				</xsl:element>
      	        			</xsl:element>
      	      		</xsl:element> 
            		</xsl:if>     
            		
             </xsl:if>
        <!-- Create Customer Order for new services  -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_co_1</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>
				<xsl:element name="lan_path_file_string">
					<xsl:value-of select="request-param[@name='lanPathFileString']"/>
				</xsl:element>
				<xsl:element name="sales_rep_dept">
					<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
				</xsl:element>
				<xsl:element name="provider_tracking_no">001v</xsl:element>	
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
                      				<xsl:if test="request-param[@name='bonusMyCompany'] = 'ADD'">        		
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:if> 				      
				      	<xsl:if test="request-param[@name='blockInternational'] = 'ADD'">        		
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_2</xsl:element>
						  	<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='blockOutsideEU'] = 'ADD'">        		
					    	<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_3</xsl:element>
						  	<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if> 
					  <xsl:if test="request-param[@name='block0190/0900'] = 'ADD'">        		
					  	<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_4</xsl:element>
						  	<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						 </xsl:element>
					  </xsl:if>
					<xsl:if test="request-param[@name='bonusMyCompany'] = 'REMOVE'">        		
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:if> 				      
					<xsl:if test="request-param[@name='blockInternational'] = 'REMOVE'">        		
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_service_2</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:if> 
					<xsl:if test="request-param[@name='blockOutsideEU'] = 'REMOVE'">        		
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_service_3</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:if> 
					<xsl:if test="request-param[@name='block0190/0900'] = 'REMOVE'">        		
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_service_4</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:if>	   
					</xsl:element> 
				</xsl:element>
			</xsl:element>
			
			<!--Release customer order for added/removed services-->                
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>						
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>					
					</xsl:element>
				</xsl:element>
				
			<!-- Create Contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">					
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>			
					<xsl:element name="contact_type_rd">MODVOIP_CONTRACT</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Modify 2nd Line VoIP contract</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
	  				    <xsl:text>&#xA;User name: </xsl:text>
                        <xsl:value-of select="request-param[@name='userName']"/>
                        <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                        <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                        <xsl:text>&#xA;Desired date: </xsl:text>
                        <xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>		
		</xsl:element>
	</xsl:element>
