<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an Add Service Subscription FIF request

  @author schwarje
-->
<!DOCTYPE XSL [
<!ENTITY GenericServiceCharacteristicList SYSTEM "GenericServiceCharacteristicList.xsl">
<!ENTITY GenericCreateAddress SYSTEM "GenericCreateAddress.xsl">
]>
<xsl:stylesheet 
    exclude-result-prefixes="dateutils" 
    version="1.0"
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

        <xsl:if test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0
        			and request-param[@name='SERVICE_CHAR_CODE'] != ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">onlyUseListsOrSimpleParameters</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Bitte CONF_SERVICE_CHAR_LIST ODER einfache Parameter nutzen, nicht beide.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>

        <xsl:if test="request-param[@name='ACTIVATE_SERVICE'] = 'Y' and
        			request-param[@name='DESIRED_DATE'] != ''">
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">noDesiredDateForAutomaticActivation</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Dienste werden bei ACTIVATE_SERVICE = Y automatisch am gleichen Tag aktiviert. In diesem Fall bitte kein DESIRED_DATE setzen.</xsl:element>
				</xsl:element>                                      
       		</xsl:element>        			
        </xsl:if>
    	
    	<xsl:if test="request-param[@name='CUST_ORDER_REF_ID'] != ''
    		and request-param[@name='requestListId'] != ''">
    		<xsl:element name="CcmFifReadExternalNotificationCmd">
    			<xsl:element name="command_id">read_customer_order</xsl:element>
    			<xsl:element name="CcmFifReadExternalNotificationInCont">
    				<xsl:element name="transaction_id">
    					<xsl:value-of select="request-param[@name='requestListId'] "/>
    				</xsl:element>
    				<xsl:element name="parameter_name">
    					<xsl:value-of select="concat(request-param[@name='CUST_ORDER_REF_ID'], '_CUSTOMER_ORDER_ID')"/>
    				</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:if>

		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>

		<xsl:variable name="desiredDate">
			<xsl:choose>
				<xsl:when test ="request-param[@name='DESIRED_DATE'] = '' or
						request-param[@name='DESIRED_DATE'] = 'today' or
						request-param[@name='ACTIVATE_SERVICE'] = 'Y'">
					<xsl:value-of select="$today"/>
				</xsl:when>
				<xsl:when test ="dateutils:compareString(request-param[@name='DESIRED_DATE'], $today) = '-1'">
					<xsl:value-of select="$today"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="desiredScheduleType">
			<xsl:choose>
				<xsl:when test ="dateutils:compareString($desiredDate, $today) = '0'">ASAP</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_service</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:choose>
					<xsl:when test="request-param[@name='PARENT_SERVICE_SUBS_ID'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID']"/>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="product_subscription_id">
							<xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
						</xsl:element>
						<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>		

		<!-- lock product to avoid concurrency problems -->
		<xsl:element name="CcmFifLockObjectCmd">
			<xsl:element name="CcmFifLockObjectInCont">
				<xsl:element name="object_id_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="object_type">PROD_SUBS</xsl:element>
			</xsl:element>
		</xsl:element>

		<xsl:element name="CcmFifGetEntityCmd">
			<xsl:element name="command_id">get_entity</xsl:element>
			<xsl:element name="CcmFifGetEntityInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>          

		<xsl:if test="request-param[@name='PARENT_SERVICE_SUBS_ID'] != ''">
	        <!-- check, if the SS matches the PS provided -->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_ps</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">productSubscription</xsl:element>
					<xsl:element name="value_type">productSubscriptionId</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
							</xsl:element>
						</xsl:element>						
					</xsl:element>
				</xsl:element>
			</xsl:element>			
		</xsl:if>

		<xsl:choose>
			<xsl:when test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0">
				<xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item">
					&GenericCreateAddress;
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				&GenericCreateAddress;
			</xsl:otherwise>
		</xsl:choose>

      <!-- Add Feature Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
          </xsl:element>
          <xsl:element name="parent_service_subs_id">
            <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$desiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">
            <xsl:value-of select="$desiredScheduleType"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <xsl:choose>
              <xsl:when test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0">
                <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item">
                  &GenericServiceCharacteristicList;
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
              	&GenericServiceCharacteristicList;
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="sub_order_id">
            <xsl:value-of select="request-param[@name='SUB_ORDER_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    	<xsl:if test="request-param[@name='CUST_ORDER_REF_ID'] != ''
    		and request-param[@name='requestListId'] != ''">
    	
	    	<!-- get data from customer order -->
	    	<xsl:element name="CcmFifGetCustomerOrderDataCmd">
	    		<xsl:element name="command_id">find_customer_order</xsl:element>
	    		<xsl:element name="CcmFifGetCustomerOrderDataInCont">
	    			<xsl:element name="customer_order_id_ref">
	    				<xsl:element name="command_id">read_customer_order</xsl:element>
	    				<xsl:element name="field_name">parameter_value</xsl:element>
	    			</xsl:element>
	    		</xsl:element>
	    	</xsl:element>
    		
    		<!-- Add STPs to customer order if exists -->
    		<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
    			<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
    				<xsl:element name="customer_order_id_ref">
    					<xsl:element name="command_id">find_customer_order</xsl:element>
    					<xsl:element name="field_name">customer_order_id</xsl:element>
    				</xsl:element>
    				<xsl:element name="service_ticket_pos_list">
    					<xsl:element name="CcmFifCommandRefCont">
    						<xsl:element name="command_id">add_service</xsl:element>
    						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
    					</xsl:element>
    				</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:if>
    	
    	<xsl:if test="request-param[@name='CUST_ORDER_REF_ID'] = ''">
			<!-- Create Customer Order -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='PROVIDER_TRACKING_NUMBER']"/>
					</xsl:element>			
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='ACTIVATE_SERVICE'] = 'Y'">
						<xsl:element name="processing_status">completedOPM</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
   		 </xsl:if>
    	
		<xsl:if test="request-param[@name='RELEASE_CUSTOMER_ORDER'] = 'Y'
			and request-param[@name='CUST_ORDER_REF_ID'] = ''">
			<!-- Release Customer Order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	
		<!-- Create Contact -->
		<xsl:if test="request-param[@name='CREATE_CONTACT'] != 'N'">
		    <xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">
						<xsl:choose>
							<xsl:when test="request-param[@name='CONTACT_TYPE_RD'] != ''">
								<xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
							</xsl:when>
							<xsl:otherwise>ADD_FEATURE_SERV</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="short_description">
						<xsl:choose>
							<xsl:when test="request-param[@name='SHORT_DESCRIPTION'] != ''">
								<xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
							</xsl:when>
							<xsl:otherwise>Dienst hinzugefügt</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:if test="request-param[@name='LONG_DESCRIPTION_TEXT'] != ''">
					    			<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
									<xsl:text>&#xA;</xsl:text>
								</xsl:if>
							    <xsl:text>Dienstenutzung </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text> (ServiceCode </xsl:text>
								<xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
								<xsl:text>) erstellt.&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>)</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
