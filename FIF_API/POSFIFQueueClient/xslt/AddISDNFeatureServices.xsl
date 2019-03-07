		<!-- Add Feature  Service V0017 Monthly Charge  -->
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_2</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0017</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">
					<xsl:value-of select="request-param[@name='reasonRd']"/>
				</xsl:element>
				<xsl:if test="$AccountNumber=''">
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">read_external_notification_2</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="$AccountNumber!=''">
					<xsl:element name="account_number">
						<xsl:value-of select="$AccountNumber"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="service_characteristic_list">				
				</xsl:element>
				<xsl:element name="detailed_reason_rd">
					<xsl:value-of select="$detailedReasonRd"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- Add Feature  Service V0020 if AoC = E -->
		<xsl:if test="request-param[@name='AoC'] = 'E'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_3</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0020</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0021- if AoC = D -->
		<xsl:if test="request-param[@name='AoC'] = 'D'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_3</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0021</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 

        <xsl:if test="request-param[@name='addCOLP'] = 'Y'">		
            <!-- Add Feature  Service V0022 Rufnummernanzeige COLP (S0)  -->			
            <xsl:element name="CcmFifAddServiceSubsCmd">
                <xsl:element name="command_id">add_service_4</xsl:element>
                <xsl:element name="CcmFifAddServiceSubsInCont">
                    <xsl:element name="product_subscription_ref">
                        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                        <xsl:element name="field_name">product_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="service_code">V0022</xsl:element>
                    <xsl:element name="parent_service_subs_ref">
                        <xsl:element name="command_id">add_service_1</xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="desired_date">
                        <xsl:value-of select="$today"/>
                    </xsl:element>
                    <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                    <xsl:element name="reason_rd">
                        <xsl:value-of select="request-param[@name='reasonRd']"/>
                    </xsl:element>
                    <xsl:if test="$AccountNumber=''">
                        <xsl:element name="account_number_ref">
                            <xsl:element name="command_id">read_external_notification_2</xsl:element>
                            <xsl:element name="field_name">parameter_value</xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="$AccountNumber!=''">
                        <xsl:element name="account_number">
                            <xsl:value-of select="$AccountNumber"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="service_characteristic_list">                        
                    </xsl:element>
                	<xsl:element name="detailed_reason_rd">
                		<xsl:value-of select="$detailedReasonRd"/>
                	</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        
        <xsl:if test="request-param[@name='addSubAddressing'] = 'Y'">		
            <!-- Add Feature  Service V0023 Subadressierung (S0)   -->			
            <xsl:element name="CcmFifAddServiceSubsCmd">
                <xsl:element name="command_id">add_service_5</xsl:element>
                <xsl:element name="CcmFifAddServiceSubsInCont">
                    <xsl:element name="product_subscription_ref">
                        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                        <xsl:element name="field_name">product_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="service_code">V0023</xsl:element>
                    <xsl:element name="parent_service_subs_ref">
                        <xsl:element name="command_id">add_service_1</xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="desired_date">
                        <xsl:value-of select="$today"/>
                    </xsl:element>
                    <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                    <xsl:element name="reason_rd">
                        <xsl:value-of select="request-param[@name='reasonRd']"/>
                    </xsl:element>
                    <xsl:if test="$AccountNumber=''">
                        <xsl:element name="account_number_ref">
                            <xsl:element name="command_id">read_external_notification_2</xsl:element>
                            <xsl:element name="field_name">parameter_value</xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="$AccountNumber!=''">
                        <xsl:element name="account_number">
                            <xsl:value-of select="$AccountNumber"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="service_characteristic_list">                        
                    </xsl:element>
                	<xsl:element name="detailed_reason_rd">
                		<xsl:value-of select="$detailedReasonRd"/>
                	</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>	

         <xsl:if test="request-param[@name='addAdditionalSignalling'] = 'Y'">		
             <!-- Add Feature  Service V0024 UUS1 Zusatzsignalisierung S0  -->			
             <xsl:element name="CcmFifAddServiceSubsCmd">
                 <xsl:element name="command_id">add_service_6</xsl:element>
                 <xsl:element name="CcmFifAddServiceSubsInCont">
                     <xsl:element name="product_subscription_ref">
                         <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                         <xsl:element name="field_name">product_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="service_code">V0024</xsl:element>
                     <xsl:element name="parent_service_subs_ref">
                         <xsl:element name="command_id">add_service_1</xsl:element>
                         <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="desired_date">
                         <xsl:value-of select="$today"/>
                     </xsl:element>
                     <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                     <xsl:element name="reason_rd">
                         <xsl:value-of select="request-param[@name='reasonRd']"/>
                     </xsl:element>
                     <xsl:if test="$AccountNumber=''">
                         <xsl:element name="account_number_ref">
                             <xsl:element name="command_id">read_external_notification_2</xsl:element>
                             <xsl:element name="field_name">parameter_value</xsl:element>
                         </xsl:element>
                     </xsl:if>
                     <xsl:if test="$AccountNumber!=''">
                         <xsl:element name="account_number">
                             <xsl:value-of select="$AccountNumber"/>
                         </xsl:element>
                     </xsl:if>
                     <xsl:element name="service_characteristic_list">                         
                     </xsl:element>
                 	<xsl:element name="detailed_reason_rd">
                 		<xsl:value-of select="$detailedReasonRd"/>
                 	</xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:if>	

         <!-- Add Feature  Service V0025 Block International   if blockInternational  is set -->
         <xsl:if test="request-param[@name='blockInternational'] = 'Y'">
             <xsl:element name="CcmFifAddServiceSubsCmd">
                 <xsl:element name="command_id">add_service_7</xsl:element>
                 <xsl:element name="CcmFifAddServiceSubsInCont">
                     <xsl:element name="product_subscription_ref">
                         <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                         <xsl:element name="field_name">product_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="service_code">V0025</xsl:element>
                     <xsl:element name="parent_service_subs_ref">
                         <xsl:element name="command_id">add_service_1</xsl:element>
                         <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="desired_date">
                         <xsl:value-of select="$today"/>
                     </xsl:element>
                     <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                     <xsl:element name="reason_rd">
                         <xsl:value-of select="request-param[@name='reasonRd']"/>
                     </xsl:element>
                     <xsl:if test="$AccountNumber=''">
                         <xsl:element name="account_number_ref">
                             <xsl:element name="command_id">read_external_notification_2</xsl:element>
                             <xsl:element name="field_name">parameter_value</xsl:element>
                         </xsl:element>
                     </xsl:if>
                     <xsl:if test="$AccountNumber!=''">
                         <xsl:element name="account_number">
                             <xsl:value-of select="$AccountNumber"/>
                         </xsl:element>
                     </xsl:if>
                     <xsl:element name="service_characteristic_list">                        
                     </xsl:element>
                 	<xsl:element name="detailed_reason_rd">
                 		<xsl:value-of select="$detailedReasonRd"/>
                 	</xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:if>
         <!-- Add Feature  Service V0026 Block Outside EU if blockOutsideEU  is set -->
         <xsl:if test="request-param[@name='blockOutsideEu'] = 'Y'">
             <xsl:element name="CcmFifAddServiceSubsCmd">
                 <xsl:element name="command_id">add_service_8</xsl:element>
                 <xsl:element name="CcmFifAddServiceSubsInCont">
                     <xsl:element name="product_subscription_ref">
                         <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                         <xsl:element name="field_name">product_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="service_code">V0026</xsl:element>
                     <xsl:element name="parent_service_subs_ref">
                         <xsl:element name="command_id">add_service_1</xsl:element>
                         <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="desired_date">
                         <xsl:value-of select="$today"/>
                     </xsl:element>
                     <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                     <xsl:element name="reason_rd">
                         <xsl:value-of select="request-param[@name='reasonRd']"/>
                     </xsl:element>
                     <xsl:if test="$AccountNumber=''">
                         <xsl:element name="account_number_ref">
                             <xsl:element name="command_id">read_external_notification_2</xsl:element>
                             <xsl:element name="field_name">parameter_value</xsl:element>
                         </xsl:element>
                     </xsl:if>
                     <xsl:if test="$AccountNumber!=''">
                         <xsl:element name="account_number">
                             <xsl:value-of select="$AccountNumber"/>
                         </xsl:element>
                     </xsl:if>
                     <!-- Bemerkung -->
                     <xsl:element name="service_characteristic_list">                         
                     </xsl:element>
                 	<xsl:element name="detailed_reason_rd">
                 		<xsl:value-of select="$detailedReasonRd"/>
                 	</xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:if>
         <!-- Add Feature  Service V0027 Block 0190/0900 if  block0190/0900  is set -->
         <xsl:if test="request-param[@name='block0190/0900'] = 'Y'">
             <xsl:element name="CcmFifAddServiceSubsCmd">
                 <xsl:element name="command_id">add_service_9</xsl:element>
                 <xsl:element name="CcmFifAddServiceSubsInCont">
                     <xsl:element name="product_subscription_ref">
                         <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                         <xsl:element name="field_name">product_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="service_code">V0027</xsl:element>
                     <xsl:element name="parent_service_subs_ref">
                         <xsl:element name="command_id">add_service_1</xsl:element>
                         <xsl:element name="field_name">service_subscription_id</xsl:element>
                     </xsl:element>
                     <xsl:element name="desired_date">
                         <xsl:value-of select="$today"/>
                     </xsl:element>
                     <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                     <xsl:element name="reason_rd">
                         <xsl:value-of select="request-param[@name='reasonRd']"/>
                     </xsl:element>
                     <xsl:if test="$AccountNumber=''">
                         <xsl:element name="account_number_ref">
                             <xsl:element name="command_id">read_external_notification_2</xsl:element>
                             <xsl:element name="field_name">parameter_value</xsl:element>
                         </xsl:element>
                     </xsl:if>
                     <xsl:if test="$AccountNumber!=''">
                         <xsl:element name="account_number">
                             <xsl:value-of select="$AccountNumber"/>
                         </xsl:element>
                     </xsl:if>
                     <xsl:element name="service_characteristic_list">                         
                     </xsl:element>
                 	<xsl:element name="detailed_reason_rd">
                 		<xsl:value-of select="$detailedReasonRd"/>
                 	</xsl:element>
                 </xsl:element>
             </xsl:element>
         </xsl:if>
      
		<xsl:if test="request-param[@name='addCLIPNoScreening'] = 'Y'">
			<!-- Add Feature  Service V0035 CLIP - no screening (S0) -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_10</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0035</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">						
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
			
			<xsl:if test="request-param[@name='closingUnitGroup'] != ''">
			    <!-- Add Feature  Service V0037 CUG Geschlossene Benutzergruppe (S0) -->
			    <xsl:element name="CcmFifAddServiceSubsCmd">
			        <xsl:element name="command_id">add_service_11</xsl:element>
			        <xsl:element name="CcmFifAddServiceSubsInCont">
			            <xsl:element name="product_subscription_ref">
			                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
			                <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element>
			            <xsl:element name="service_code">V0037</xsl:element>
			            <xsl:element name="parent_service_subs_ref">
			                <xsl:element name="command_id">add_service_1</xsl:element>
			                <xsl:element name="field_name">service_subscription_id</xsl:element>
			            </xsl:element>
			            <xsl:element name="desired_date">
			                <xsl:value-of select="$today"/>
			            </xsl:element>
			            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
			            <xsl:element name="reason_rd">
			                <xsl:value-of select="request-param[@name='reasonRd']"/>
			            </xsl:element>
			            <xsl:if test="$AccountNumber=''">
			                <xsl:element name="account_number_ref">
			                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
			                    <xsl:element name="field_name">parameter_value</xsl:element>
			                </xsl:element>
			            </xsl:if>
			            <xsl:if test="$AccountNumber!=''">
			                <xsl:element name="account_number">
			                    <xsl:value-of select="$AccountNumber"/>
			                </xsl:element>
			            </xsl:if>
			            <xsl:element name="service_characteristic_list">
			            	<xsl:element name="CcmFifConfiguredValueCont">
			            		<xsl:element name="service_char_code">V0083</xsl:element>
			            		<xsl:element name="data_type">STRING</xsl:element>
			            		<xsl:element name="configured_value">
			            			<xsl:value-of select="request-param[@name='closingUnitGroup']"/>
			            		</xsl:element>
			            	</xsl:element>	  
			            </xsl:element>
			        	<xsl:element name="detailed_reason_rd">
			        		<xsl:value-of select="$detailedReasonRd"/>
			        	</xsl:element>			        	
			        </xsl:element>
			    </xsl:element>
			</xsl:if>
			
			<!-- Add Features for serviceLevel -->
			<xsl:if test="request-param[@name='serviceLevel'] != ''">
			    <xsl:element name="CcmFifAddServiceSubsCmd">
			        <xsl:element name="command_id">add_service_12</xsl:element>
			        <xsl:element name="CcmFifAddServiceSubsInCont">
			            <xsl:element name="product_subscription_ref">
			                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
			                <xsl:element name="field_name">product_subscription_id</xsl:element>
			            </xsl:element>
			            <xsl:element name="service_code">
			            	<xsl:choose>
			            		<xsl:when test="request-param[@name='serviceLevel'] = 'Basis'">V0039</xsl:when>
			            		<!--<xsl:when test="request-param[@name='serviceLevel'] = 'Premium'">V0064</xsl:when>-->
			            		<xsl:when test="request-param[@name='serviceLevel'] = 'classic'">S0106</xsl:when>
			            		<xsl:when test="request-param[@name='serviceLevel'] = 'classicPlus'">V0070</xsl:when>
			            		<xsl:when test="request-param[@name='serviceLevel'] = 'premium'">V0459</xsl:when>
			            		<xsl:when test="request-param[@name='serviceLevel'] = 'comfort'">V0461</xsl:when>
			            	</xsl:choose>
			            </xsl:element>
			            <xsl:element name="parent_service_subs_ref">
			                <xsl:element name="command_id">add_service_1</xsl:element>
			                <xsl:element name="field_name">service_subscription_id</xsl:element>
			            </xsl:element>
			            <xsl:element name="desired_date">
			                <xsl:value-of select="$today"/>
			            </xsl:element>
			            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
			            <xsl:element name="reason_rd">
			                <xsl:value-of select="request-param[@name='reasonRd']"/>
			            </xsl:element>
			            <xsl:if test="$AccountNumber=''">
			                <xsl:element name="account_number_ref">
			                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
			                    <xsl:element name="field_name">parameter_value</xsl:element>
			                </xsl:element>
			            </xsl:if>
			            <xsl:if test="$AccountNumber!=''">
			                <xsl:element name="account_number">
			                    <xsl:value-of select="$AccountNumber"/>
			                </xsl:element>
			            </xsl:if>
			            <xsl:element name="service_characteristic_list">
			            </xsl:element>
			        	<xsl:element name="detailed_reason_rd">
			        		<xsl:value-of select="$detailedReasonRd"/>
			        	</xsl:element>			        	
			        </xsl:element>
			    </xsl:element>
			</xsl:if> 
		
		<xsl:if test="request-param[@name='addCOLPNoScreening'] = 'Y'">
		    <!-- Add Feature  Service V0036 COLP - no screening (S0)) -->
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_13</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		        	<xsl:element name="service_code">V0036</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">		                
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>
		        </xsl:element>
		    </xsl:element>
		</xsl:if>
		
		<xsl:if test="request-param[@name='addForwardCall'] = 'Y'">
			<!-- Add Feature  Service V0059 Anrufweiterschaltung -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_14</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0059</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">						
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		
		<xsl:if test="request-param[@name='addCLIP'] = 'Y'">
		    <!-- Add Feature  Service V0063 Rufnummernanzeige  -->			
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_15</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0063</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">		                
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>
		        </xsl:element>
		    </xsl:element>
		</xsl:if>
		
		<xsl:if test="request-param[@name='addCCBS'] = 'Y'">		
		    <!-- Add Feature  Service V0065 CCBS Rückruf bei besetzt  -->			
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_17</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0065</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">		                
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>
		        </xsl:element>
		    </xsl:element>
		</xsl:if>
		
		<xsl:if test="request-param[@name='addCW/TOG'] = 'Y'">	
		    <!-- Add Feature  Service V0066 CW/TOG Anklopfen, Makeln -->
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_18</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0066</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">		                
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>
		        </xsl:element>
		    </xsl:element>
		</xsl:if>
		
		<xsl:if test="request-param[@name='add3PTY'] = 'Y'">	
		    <!-- Add Feature  Service V0067 3PTY Dreierkonferenz  -->		
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_19</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0067</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>
		        </xsl:element>
		    </xsl:element>
		</xsl:if>		
		
		<xsl:if test="request-param[@name='suppressCallerID'] != ''">		
		    <!-- Add Feature  Service V0068 Rufnummernunterdrückung (CLIR)  -->			
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_20</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0068</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">
		            	<xsl:element name="CcmFifConfiguredValueCont">
		            		<xsl:element name="service_char_code">V0085</xsl:element>
		            		<xsl:element name="data_type">STRING</xsl:element>
		            		<xsl:element name="configured_value">
		            			<xsl:value-of select="request-param[@name='suppressCallerID']"/>
		            		</xsl:element>
		            	</xsl:element>	   
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>		        	
		        </xsl:element>
		    </xsl:element>
		</xsl:if>
		
		<xsl:if test="request-param[@name='suppressCallingNumber'] != ''">		
		    <!-- Add Feature  Service V0069 k. Anzeige anrufende Nr (COLR)  -->			
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_21</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0069</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">
		            	<xsl:element name="CcmFifConfiguredValueCont">
		            		<xsl:element name="service_char_code">V0086</xsl:element>
		            		<xsl:element name="data_type">STRING</xsl:element>
		            		<xsl:element name="configured_value">
		            			<xsl:value-of select="request-param[@name='suppressCallingNumber']"/>
		            		</xsl:element>
		            	</xsl:element>		                
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>		        	
		        </xsl:element>
		    </xsl:element>
		</xsl:if>
		
		<!-- Add Feature  Service V0081 Monatspreis happy Sunday  -->
		<xsl:if test="request-param[@name='addHappySundayMonthlyCharge'] = 'Y'">
    		<xsl:element name="CcmFifAddServiceSubsCmd">
    			<xsl:element name="command_id">add_service_22</xsl:element>
    			<xsl:element name="CcmFifAddServiceSubsInCont">
    				<xsl:element name="product_subscription_ref">
    					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
    					<xsl:element name="field_name">product_subscription_id</xsl:element>
    				</xsl:element>
    				<xsl:element name="service_code">V0081</xsl:element>
    				<xsl:element name="parent_service_subs_ref">
    					<xsl:element name="command_id">add_service_1</xsl:element>
    					<xsl:element name="field_name">service_subscription_id</xsl:element>
    				</xsl:element>
    				<xsl:element name="desired_date">
    						<xsl:value-of select="$today"/>
    				</xsl:element>
    				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
    				<xsl:element name="reason_rd">
    					<xsl:value-of select="request-param[@name='reasonRd']"/>
    				</xsl:element>
    				<xsl:if test="$AccountNumber=''">
    					<xsl:element name="account_number_ref">
    						<xsl:element name="command_id">read_external_notification_2</xsl:element>
    						<xsl:element name="field_name">parameter_value</xsl:element>
    					</xsl:element>
    				</xsl:if>
    				<xsl:if test="$AccountNumber!=''">
    					<xsl:element name="account_number">
    						<xsl:value-of select="$AccountNumber"/>
    					</xsl:element>
    				</xsl:if>
    				<xsl:element name="service_characteristic_list">    				
    				</xsl:element>
    				<xsl:element name="detailed_reason_rd">
    					<xsl:value-of select="$detailedReasonRd"/>
    				</xsl:element>
    			</xsl:element>
    		</xsl:element>
        </xsl:if>
		<!-- Add Feature  Service V0099 Bonus My Company  if bonusMyCompany is set -->
		<xsl:if test="request-param[@name='bonusMyCompany'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_23</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0099</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<!-- Bemerkung -->
					<xsl:element name="service_characteristic_list">					
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		
		<!-- Add Feature  Service V0111 if setupByTechnician = Y -->
		<xsl:if test="request-param[@name='setupByTechnician'] = 'Y'">
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		        <xsl:element name="command_id">add_service_25</xsl:element>
		        <xsl:element name="CcmFifAddServiceSubsInCont">
		            <xsl:element name="product_subscription_ref">
		                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                <xsl:element name="field_name">product_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="service_code">V0111</xsl:element>
		            <xsl:element name="parent_service_subs_ref">
		                <xsl:element name="command_id">add_service_1</xsl:element>
		                <xsl:element name="field_name">service_subscription_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="desired_date">
		                <xsl:value-of select="$today"/>
		            </xsl:element>
		            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		            <xsl:element name="reason_rd">
		                <xsl:value-of select="request-param[@name='reasonRd']"/>
		            </xsl:element>
		            <xsl:if test="$AccountNumber=''">
		                <xsl:element name="account_number_ref">
		                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
		                    <xsl:element name="field_name">parameter_value</xsl:element>
		                </xsl:element>
		            </xsl:if>
		            <xsl:if test="$AccountNumber!=''">
		                <xsl:element name="account_number">
		                    <xsl:value-of select="$AccountNumber"/>
		                </xsl:element>
		            </xsl:if>
		            <xsl:element name="service_characteristic_list">
		            </xsl:element>
		        	<xsl:element name="detailed_reason_rd">
		        		<xsl:value-of select="$detailedReasonRd"/>
		        	</xsl:element>
		        </xsl:element>
		    </xsl:element>
		</xsl:if> 		
		<!-- Add Feature  Service V0254 Sperre 0137   if block0137calls  is set -->
		<xsl:if test="request-param[@name='block0137Calls'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_26</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0254</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">					
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0255 Sperre 01805 Calls   if block01805calls  is set -->
		<xsl:if test="request-param[@name='block01805Calls'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_27</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0255</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">				
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0256 Sperre  Premium  if blockPremium  is set -->
		<xsl:if test="request-param[@name='blockPremiumCalls'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_28</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0256</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">				
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0257 Sperre abgehender Verkehr  if blockOutgoingTraffic  is set -->
		<xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_29</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0257</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">			
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0258 Sperre abgehender Verkehr(Ausname Ortsgesprache,0800,011xy)  if blockOutgoingTrafficExceptLocal  is set -->
		<xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_30</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0258</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">				
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0259 Sperre MobilFunk  if blockMobileNumbers  is set -->
		<xsl:if test="request-param[@name='blockMobileNumbers'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_31</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0259</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">					
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 
		<!-- Add Feature  Service V0260 Sperre 0900  if block0900  is set -->
		<xsl:if test="request-param[@name='block0900'] = 'Y'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_32</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0260</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">						
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 

		<xsl:if test="request-param[@name='block118xy'] = 'Y'">
		    <!-- Add Feature  Service V0261 Sperre 118xy  if block118xy  is set -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_33</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0261</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if> 

		<xsl:if test="request-param[@name='addConnectAnalogChanger'] = 'Y'">
			<!-- Add Feature  Service V0120 Freischaltung analog - Wechsler -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_34</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0120</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="request-param[@name='addConnectISDNChanger'] = 'Y'">
			<!-- Add Feature  Service V0119 Freischaltung ISDN - Wechsler -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_35</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0119</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">						
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>	
		</xsl:if>

		<xsl:if test="request-param[@name='addNotifier'] = 'Y'">
			<!-- Notifier V0039 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_36</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0039</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">						
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>	
		</xsl:if>
		
		<xsl:if test="request-param[@name='addTP'] = 'Y'">
			<!-- Umstecken am Bus V0064  -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_37</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0064</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reasonRd']"/>
					</xsl:element>
					<xsl:if test="$AccountNumber=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$AccountNumber!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="$AccountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">						
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>	
		</xsl:if>
