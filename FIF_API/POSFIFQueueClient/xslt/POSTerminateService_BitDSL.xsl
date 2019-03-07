<xsl:element name="CcmFifCommandList">
	<xsl:element name="transaction_id">
		<xsl:value-of select="request-param[@name='transactionID']"/>
	</xsl:element>
	<xsl:element name="client_name">
		<xsl:value-of select="request-param[@name='clientName']"/>
	</xsl:element>
	<xsl:variable name="TopAction" select="//request/action-name"/>
	<xsl:element name="action_name">
		<xsl:value-of select="concat($TopAction, '_BitDsl')"/>
	</xsl:element>   
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='overrideSystemDate']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <!-- Find Service Subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">                
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Ensure that characteristic V0138 on main access service is not equal to OPAL -->
      <xsl:element name="CcmFifValidateCharacteristicValueCmd">
        <xsl:element name="command_id">valid_char_value_1</xsl:element>
        <xsl:element name="CcmFifValidateCharacteristicValueInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0138</xsl:element>
          <xsl:element name="configured_value">OPAL</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Ensure that the termination has not been performed before -->
      <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
        <xsl:element name="command_id">find_cancel_stp_1</xsl:element>
        <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_rd">TERMINATION</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure Service Subscription -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:if test="request-param[@name='reasonRd'] != ''">
            <xsl:element name="reason_rd">
              <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='reasonRd'] = ''">
            <xsl:element name="reason_rd">TERMINATION</xsl:element>
          </xsl:if>	
          <xsl:element name="service_characteristic_list">
            <!-- Projektauftrag -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0104</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">nein</xsl:element>                   			
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>            
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$terminationDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Kündigungsgrund -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0137</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='terminationReason']"/>
              </xsl:element>
            </xsl:element>
            <!-- Sonderzeitfenster -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0139</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NZF</xsl:element>
            </xsl:element>
            <!-- Fixer Bestelltermin -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0140</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nein</xsl:element>
            </xsl:element>  
            <!-- Order Variant -->
            <xsl:element name="CcmFifConfiguredValueCont"> 
              <xsl:element name="service_char_code">V0810</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Echte Kündigung</xsl:element>
            </xsl:element> 			
          </xsl:element>
        </xsl:element>
      </xsl:element>
     
      <xsl:if test="request-param[@name='keepMMAccessHardware'] != ''">	
        &HandleMMAccessHardware;
      </xsl:if>
      
      <!-- Terminate Product Subscription -->
      <xsl:element name="CcmFifTerminateProductSubsCmd">
        <xsl:element name="command_id">terminate_ps_1</xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:if test="request-param[@name='reasonRd'] != ''">
            <xsl:element name="reason_rd">
              <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='reasonRd'] = ''">
            <xsl:element name="reason_rd">TERMINATION</xsl:element>
          </xsl:if>	
          <xsl:element name="auto_customer_order">N</xsl:element>
          <xsl:element name="detailed_reason_rd">
	     	<xsl:value-of select="request-param[@name='terminationReason']"/>
	      </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for Reconfiguration -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
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
<!--          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
            <xsl:element name="provider_tracking_no">001</xsl:element> 
          </xsl:if>
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
          </xsl:if> -->
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
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_hardware_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>     
      
      <!-- Create Customer Order for Termination -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parent_customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
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
          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
            <xsl:element name="provider_tracking_no">002</xsl:element> 
          </xsl:if>
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
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
              <xsl:element name="command_id">terminate_ps_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
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
        </xsl:element>
      </xsl:element>
      
      
      <!-- Release Customer Order for Termination -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
          <xsl:element name="short_description">Automatische Kündigung</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Kündigung der Produktnutzung für Dienst </xsl:text>
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            <xsl:text> durch </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/> 
            <xsl:text>.&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>				  
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
	</xsl:element>
</xsl:element>		  
