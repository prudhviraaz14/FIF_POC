<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated relocation FIF request

  @author goethalo
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
		<xsl:element name="client_name">KBA</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<!-- Generate a FIF date that is one day before the relocation date -->
			<xsl:variable name="oneDayBefore" select="dateutils:createFIFDateOffset(request-param[@name='relocationDate'], 'DATE', '-1')"/>
			<!-- Convert the termination date to OPM format -->
			<xsl:variable name="relocationDateOPM" select="dateutils:createOPMDate(request-param[@name='relocationDate'])"/>
			<!-- Ensure that either accessNumber, serviceTicketPositionId or serviceSubscriptionId are provided -->
			<xsl:if test="(request-param[@name='accessNumber'] = '') and
        (request-param[@name='serviceTicketPositionId'] = '')  and
        (request-param[@name='serviceSubscriptionId'] = '')">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">create_find_ss_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">At least one of the following params must be provided:
              accessNumber, serviceTicketPositionId or serviceSubscriptionId.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:if test="((request-param[@name='accessNumber'] != '' )and
            ((request-param[@name='serviceTicketPositionId'] = '') and
            (request-param[@name='serviceSubscriptionId'] = '')))">
						<xsl:element name="access_number">
							<xsl:value-of select="request-param[@name='accessNumber']"/>
						</xsl:element>
						<xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
					</xsl:if>
					<xsl:if test="(request-param[@name='serviceTicketPositionId'] != '') and
            (request-param[@name='serviceSubscriptionId'] = '')">
						<xsl:element name="service_ticket_position_id">
							<xsl:value-of select="request-param[@name='serviceTicketPositionId']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contract_number">
						<xsl:value-of select="request-param[@name='contractNumber']"/>
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
			<!-- Ensure that the relocation has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">find_cancel_stp__1</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">RELOCATION</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Validate if account is owned by the customer-->
			<xsl:element name="CcmFifValidateObjectOwnerCmd">
				<xsl:element name="command_id">validate_object_owner_1</xsl:element>
				<xsl:element name="CcmFifValidateObjectOwnerInCont">
					<xsl:element name="object_type">AC</xsl:element>
					<xsl:element name="object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="raise_error">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Get Billing Address (only if the billing address needs to be changed -->
			<xsl:if test="request-param[@name='changeBillingAddress'] = 'Y'">
				<xsl:element name="CcmFifGetBillingAddressCmd">
					<xsl:element name="command_id">get_bill_addr_1</xsl:element>
					<xsl:element name="CcmFifGetBillingAddressInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='relocationDate']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_object_owner_1</xsl:element>
							<xsl:element name="field_name">is_owned_ind</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Get Entity Information -->
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity_1</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Get Access Information -->
			<xsl:element name="CcmFifGetAccessInfoCmd">
				<xsl:element name="command_id">get_access_info_1</xsl:element>
				<xsl:element name="CcmFifGetAccessInfoInCont">
					<xsl:element name="access_information_ref">
						<xsl:element name="command_id">get_entity_1</xsl:element>
						<xsl:element name="field_name">primary_access_info_id</xsl:element>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='relocationDate']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Modify Billing Address (only if requested) -->
			<xsl:if test="request-param[@name='changeBillingAddress'] = 'Y'">
				<xsl:element name="CcmFifModifyAddressCmd">
					<xsl:element name="command_id">modify_addr_1</xsl:element>
					<xsl:element name="CcmFifModifyAddressInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='relocationDate']"/>
						</xsl:element>
						<xsl:element name="address_ref">
							<xsl:element name="command_id">get_bill_addr_1</xsl:element>
							<xsl:element name="field_name">address_id</xsl:element>
						</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='newStreet']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='newNumber']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='newNumberSuffix']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='newPostalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='newCity']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='newCitySuffix']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_object_owner_1</xsl:element>
							<xsl:element name="field_name">is_owned_ind</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Modify Customer Address (only if requested) -->
			<xsl:if test="request-param[@name='changeCustomerAddress'] = 'Y'">
				<xsl:element name="CcmFifModifyAddressCmd">
					<xsl:element name="command_id">modify_addr_2</xsl:element>
					<xsl:element name="CcmFifModifyAddressInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='relocationDate']"/>
						</xsl:element>
						<xsl:element name="address_ref">
							<xsl:element name="command_id">get_entity_1</xsl:element>
							<xsl:element name="field_name">primary_address_id</xsl:element>
						</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='newStreet']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='newNumber']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='newNumberSuffix']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='newPostalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='newCity']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='newCitySuffix']"/>
						</xsl:element>				
                     </xsl:element>
				</xsl:element>
			</xsl:if>		
				
			<!-- Create Location Address -->
	    <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_addr_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <!-- HH 31.07.2003 : Added missing element "address_type", defaulted to "LOKA" -->
	      <xsl:element name="address_type">LOKA</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='newStreet']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='newNumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='newNumberSuffix']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='newPostalCode']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='newCity']"/>
          </xsl:element>
          <xsl:element name="city_suffix_name">
            <xsl:value-of select="request-param[@name='newCitySuffix']"/>
          </xsl:element> 
          <!-- Added missing element "country_code",defaulted to "DE" -->
   		  <xsl:element name="country_code">DE</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate Future Dated Apply Exists -->
	  <xsl:element name="CcmFifValidateFutureDatedApplyExistsCmd">
        <xsl:element name="command_id">validate_future_apply_1</xsl:element>
        <xsl:element name="CcmFifValidateFutureDatedApplyExistsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>  
      
 	  <!-- Get Order Form Data -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Get Price Plan Data -->
	  <xsl:element name="CcmFifGetPricePlanDataForProductSubsCmd">
        <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
        <xsl:element name="CcmFifGetPricePlanDataForProductSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="new_data_only_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>  
      
 	  <!-- Rollback Apply New Pricing Structure -->
	  <xsl:element name="CcmFifRollbackApplyNewPriceStructCmd">
        <xsl:element name="command_id">rollback_1</xsl:element>
        <xsl:element name="CcmFifRollbackApplyNewPriceStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ORDERFORM</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- Clone Product Subscription -->
	  <xsl:element name="CcmFifCloneProductSubsCmd">
        <xsl:element name="command_id">clone_product_1</xsl:element>
        <xsl:element name="CcmFifCloneProductSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='relocationDate']"/>
          </xsl:element>
          <xsl:element name="service_code_list"> 
			<!-- Pass in the list of service codes -->
		    <xsl:for-each select="request-param-list[@name='newServiceCodeList']/request-param-list-item">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">
                  <xsl:value-of select="request-param"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
 		  <!-- Specify the service code of the directory entry service -->
          <xsl:element name="directory_entry_service_code">V0100</xsl:element>
          <xsl:element name="service_characteristic_list">  
          
			<!-- Characteristics for service code V0010 and V0011 -->
			<xsl:if test="(request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0010'])
                       or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0011'])">
			<!-- Alter Anschluss -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0094</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">keiner</xsl:element>
              </xsl:element>
			<!-- New location -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
                <xsl:element name="service_char_code">V0014</xsl:element>
                <xsl:element name="data_type">ADDRESS</xsl:element>
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">create_addr_1</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
                </xsl:element>
            </xsl:element>
			<!-- Alter TNB -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0060</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">DTAG</xsl:element>
            </xsl:element>
			<!-- Carrier -->
	        <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0081</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='carrier']"/>
                </xsl:element>
              </xsl:element> 
			<!-- Anschlussinhaberadresse -->
	        <xsl:element name="CcmFifAddressCharacteristicCont">
                <xsl:element name="service_char_code">V0126</xsl:element>
                <xsl:element name="data_type">ADDRESS</xsl:element>
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">get_entity_1</xsl:element>
                  <xsl:element name="field_name">primary_address_id</xsl:element>
                </xsl:element>
            </xsl:element>
			<!-- Projektauftrag -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0104</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">nein</xsl:element>
            </xsl:element>
			<!-- Name/Firma 1. Anschlussinhaber -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0127</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value_ref">
                  <xsl:element name="command_id">get_entity_1</xsl:element>
                  <xsl:element name="field_name">surname</xsl:element>
                </xsl:element>
            </xsl:element>
			<!-- Vorname 1. Anschlussinhaber -->
		    <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0128</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value_ref">
                  <xsl:element name="command_id">get_entity_1</xsl:element>
                  <xsl:element name="field_name">forename</xsl:element>
                </xsl:element>
            </xsl:element>
			<!-- Automatische Versand -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0131</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
			<!-- Anzahl der alte Anschlusse -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0132</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>
			<!-- Typ der Neuschaltung -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0133</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">Neuanschluss</xsl:element>
            </xsl:element>
			<!-- Anzahl der neue Rufnummern -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0936</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='accessNumberCount']"/>
                </xsl:element>
            </xsl:element>
			<!-- ONKZ -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0124</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='ONKZ']"/>
                </xsl:element>
            </xsl:element>
			<!-- Auftragsvariante -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0810</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
                  <xsl:element name="configured_value">Umzug ohne Rufnummernübernahme</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernmitnahme'">
                  <xsl:element name="configured_value">Umzug mit Rufnummernübernahme</xsl:element>
                </xsl:if>
            </xsl:element>
			<!-- Aktivierungsdatum-->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0909</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="$relocationDateOPM"/>
                </xsl:element>
            </xsl:element>
			<!-- Anschlussbereich_kennz. -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0934</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='ASBNumber']"/>
                </xsl:element>
            </xsl:element>
			<!-- Grund der Neukonfiguration -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0943</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
                  <xsl:element name="configured_value">unbekannt</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernmitnahme'">
                  <xsl:element name="configured_value">Umzug mit Rufnummernuebernahme</xsl:element>
                </xsl:if>
              </xsl:element> 
			<!-- Bearbeitungsart -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0971</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
			<!-- Ruckrufnummer -->
             <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0125</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value_ref">
                  <xsl:element name="command_id">get_access_info_1</xsl:element>
                  <xsl:element name="field_name">phone_number</xsl:element>
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
			<!-- DTAG-Freitext -->
			<xsl:element name="CcmFifConfiguredValueCont">
                 <xsl:element name="service_char_code">V0141</xsl:element>
                 <xsl:element name="data_type">STRING</xsl:element>
                 <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
			<!-- Aktivierungszeit -->
			<xsl:element name="CcmFifConfiguredValueCont">
                 <xsl:element name="service_char_code">V0940</xsl:element>
                 <xsl:element name="data_type">STRING</xsl:element>
                 <xsl:element name="configured_value">12</xsl:element>
            </xsl:element>
			<!-- Leitungstyp -->
			<xsl:if test="request-param[@name='lineType'] != ''">
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0138</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='lineType']"/>
                  </xsl:element>
                </xsl:element>
            </xsl:if>
			<!-- IT-11106: Provisioning Provider - Version to use AFTER cut-off -->
			<xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0147</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:if test="request-param[@name='carrier'] != 'ISIS'">
				  <xsl:element name="configured_value">Arcor</xsl:element>
		       </xsl:if>
                <xsl:if test="request-param[@name='carrier'] = 'ISIS'">
                  <xsl:if test="request-param[@name='provisioningProvider'] = 'ISIS'">
				    <xsl:element name="configured_value">ISIS</xsl:element>
   		   </xsl:if>				
                  <xsl:if test="request-param[@name='provisioningProvider'] = 'Arcor'">
                  	<xsl:if test="request-param[@name='lineType'] = 'CuDa'">
				      <xsl:element name="configured_value">Arcor</xsl:element>
		        </xsl:if>
			 <xsl:if test="request-param[@name='lineType'] != 'CuDa'">  
				      <xsl:element name="configured_value">ISIS</xsl:element>
				    </xsl:if>				    	
   		          </xsl:if>				     		          
   		        </xsl:if>  
              </xsl:element>			  
            </xsl:if>  
            
			<!-- Characteristics for service code V0010 -->
			<xsl:if test="request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0010']">
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
			<!-- Ruffnummer -->
            <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0001</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0070</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
                </xsl:element>   
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0071</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0072</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0073</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0074</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0075</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0076</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0077</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
            </xsl:element>
			<!-- Weitere Ruffnummern -->
			<xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0078</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code"/>
                  <xsl:element name="city_code"/>
                  <xsl:element name="local_number"/>
                </xsl:element>
              </xsl:if>
            </xsl:if>
            
			<!-- Characteristics for service code V0011 -->
			<xsl:if test="request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0011']">
				<xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
					<!-- Access Number Range -->
					<xsl:element name="CcmFifAccessNumberCont">
						<xsl:element name="service_char_code">V0002</xsl:element>
						<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
						<xsl:element name="country_code"/>
						<xsl:element name="city_code"/>
						<xsl:element name="local_number"/>
					</xsl:element>
					<!-- Access Number Range -->
					<xsl:element name="CcmFifAccessNumberCont">
						<xsl:element name="service_char_code">V0016</xsl:element>
						<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
						<xsl:element name="country_code"/>
						<xsl:element name="city_code"/>
						<xsl:element name="local_number"/>
					</xsl:element>
					<!-- Access Number Range -->
					<xsl:element name="CcmFifAccessNumberCont">
						<xsl:element name="service_char_code">W9002</xsl:element>
						<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
						<xsl:element name="country_code"/>
						<xsl:element name="city_code"/>
						<xsl:element name="local_number"/>
					</xsl:element>
					<!-- Access Number Range -->
					<xsl:element name="CcmFifAccessNumberCont">
						<xsl:element name="service_char_code">W9003</xsl:element>
						<xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
						<xsl:element name="country_code"/>
						<xsl:element name="city_code"/>
						<xsl:element name="local_number"/>
					</xsl:element>
				</xsl:if>
			</xsl:if>
			
			<!-- Characteristics for service code V0010 till V0016 -->
			<xsl:if test="(request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0010'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0011'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0012'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0013'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0014'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0015'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0016'])">
				<!-- Bemerkung -->
				<xsl:element name="CcmFifConfiguredValueCont">
					<xsl:element name="service_char_code">V0008</xsl:element>
					<xsl:element name="data_type">STRING</xsl:element>
					<xsl:element name="configured_value">
						<xsl:text>Umzug/</xsl:text>
						<xsl:value-of select="request-param[@name='relocationDate']"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="request-param[@name='userName']"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Characteristics for service code V0010, V0011, and V0012 -->
			<xsl:if test="(request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0010'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0011'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0012'])">
				<!-- Neuer TNB -->
				<xsl:element name="CcmFifConfiguredValueCont">
					<xsl:element name="service_char_code">V0061</xsl:element>
					<xsl:element name="data_type">STRING</xsl:element>
					<xsl:element name="configured_value">Arcor</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Characteristics for service code V0010 and V0011 -->
			<xsl:if test="(request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0010'])
                          or (request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0011'])">
				<!-- Lage TAE -->
				<xsl:element name="CcmFifConfiguredValueCont">
					<xsl:element name="service_char_code">V0123</xsl:element>
					<xsl:element name="data_type">STRING</xsl:element>
					<xsl:element name="configured_value">
						<xsl:value-of select="request-param[@name='TAEType']"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Characteristics for service code V0100 -->
			<xsl:if test="(request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0100'])">
				<!-- Directory Entry -->
				<xsl:element name="CcmFifDirectoryEntryCont">
					<xsl:element name="service_char_code">V0100</xsl:element>
					<xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
					<xsl:element name="street_name">
						<xsl:value-of select="request-param[@name='newStreet']"/>
					</xsl:element>
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='newNumber']"/>
					</xsl:element>
					<xsl:element name="street_number_suffix">
						<xsl:value-of select="request-param[@name='newNumberSuffix']"/>
					</xsl:element>
					<xsl:element name="postal_code">
						<xsl:value-of select="request-param[@name='newPostalCode']"/>
					</xsl:element>
					<xsl:element name="city_name">
						<xsl:value-of select="request-param[@name='newCity']"/>
					</xsl:element>
					<!-- HH 31.07.2003 : Changed "city_suffix_name" to "city_suffix" -->
					<xsl:element name="city_suffix">
						<xsl:value-of select="request-param[@name='newCitySuffix']"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			</xsl:element>
			<!-- service code main access service -->
		    <xsl:element name="main_access_service_code_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>            
        </xsl:element>
      </xsl:element>
      
 	  <!-- Renegotiate Order Form -->
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_of_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="currency_rd_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">currency_rd</xsl:element>
          </xsl:element>
          <xsl:element name="language_rd_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">language_rd</xsl:element>
          </xsl:element>
          <xsl:element name="loi_indicator_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">loi_indicator</xsl:element>
          </xsl:element>
          <xsl:element name="notice_per_dur_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">notice_per_dur_value</xsl:element>
          </xsl:element>
          <xsl:element name="notice_per_dur_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">notice_per_dur_unit</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_per_dur_value</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_per_dur_unit</xsl:element>
          </xsl:element>
          <xsl:element name="term_start_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">term_start_date</xsl:element>
          </xsl:element>
          <xsl:element name="monthly_order_entry_amount_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">monthly_order_entry_amount</xsl:element>
          </xsl:element>
          <xsl:element name="termination_restriction_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">termination_restriction</xsl:element>
          </xsl:element>
          <xsl:element name="doc_template_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">doc_template_name</xsl:element>
          </xsl:element>
          <xsl:element name="product_commit_list_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">product_commit_list</xsl:element>
          </xsl:element>          
          <xsl:element name="min_period_start_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_period_start_date</xsl:element>
          </xsl:element>
          <xsl:element name="auto_extent_period_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">auto_extent_period_value</xsl:element>
          </xsl:element>
          <xsl:element name="auto_extent_period_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">auto_extent_period_unit</xsl:element>
          </xsl:element>
          <xsl:element name="auto_extension_ind_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">auto_extension_ind</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>  
      
	  <!-- Sign Order Form -->
	  <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_of_1</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="board_sign_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">board_sign_name</xsl:element>
          </xsl:element>
          <xsl:element name="board_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">board_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">primary_cust_sign_name</xsl:element>
          </xsl:element>
          <xsl:element name="primary_cust_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">primary_cust_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">secondary_cust_sign_name</xsl:element>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">secondary_cust_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- Apply New Pricing Structure -->
	  <xsl:element name="CcmFifApplyNewPricingStructCmd">
        <xsl:element name="command_id">apply_new_ps_1</xsl:element>
        <xsl:element name="CcmFifApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="apply_swap_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
       <!-- Configure price plans of original product subscription -->
       <!-- Find Price Plan Subscriptions with summary account for original PS -->
       <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_original_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="summary_account_ind">Y</xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
       </xsl:element>
       
       <!-- Configure summary accounts of PPS of the original PS -->
	   <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_original_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_original_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
       
	  <!-- Configure selected destinations of PPS of the original PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_original_pps_2</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_dest_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="selected_destinations_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_destinations_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- Configure contributing items of PPS of the original PS -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="command_id">configure_original_pps_3</xsl:element>
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">cont_item_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="contributing_item_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">contributing_item_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>  
      
	  <!-- Configure option values of PPS of the original PS -->
	  <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_original_pps_4</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="pps_option_value_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_name</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
           
	  <!-- Configure price plans of original product subscription -->
	  <!-- Find Price Plan Subscriptions with summary account for cloned PS -->
	  <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_cloned_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_product_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="summary_account_ind">Y</xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- Configure summary accounts of PPS of the original PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_cloned_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_cloned_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Configure selected destinations of PPS of the cloned PS -->
	  <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_cloned_pps_2</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_product_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_dest_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="selected_destinations_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_destinations_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element> 
      
	  <!-- Configure contributing items of PPS of the cloned PS -->
	  <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="command_id">configure_cloned_pps_3</xsl:element>
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_product_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">cont_item_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="contributing_item_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">contributing_item_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>   
      
      <!-- Configure option values of PPS of the cloned PS -->
	  <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_cloned_pps_4</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_product_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="pps_option_value_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_name</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
                
	  <!-- look for a voice-online bundle (item) -->
	  <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- add the new voice-online bundle item -->
	  <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">clone_product_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>        
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element> 
      
      <!-- remove the old voice-online bundle item -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_2</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_item_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_item_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>          
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>        
          <xsl:element name="action_name">REMOVE</xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- Create Customer Orders for Cloning of 'normal' Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003</xsl:element>
          <xsl:element name="service_ticket_pos_list_ref">
            <xsl:element name="command_id">clone_product_1</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
       
	  <!-- Create Customer Order for Cloning of Directory Entry service.  Only if the V0100 service is in the service code list. -->
	  <xsl:if test="request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0100']">
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_2</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="provider_tracking_no">004</xsl:element>    
			<!-- HH 31.07.2003 : Definition of "CcmFifCommandRefCont" should be element of "service_ticket_pos_list" -->
			<xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">clone_product_1</xsl:element>
                <xsl:element name="field_name">directory_entry_stp</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
	  <!-- Release Customer Orders for Cloning of 'normal' Services -->
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
      
	  <!-- Release Customer Order for Cloning of Directory Entry service.  Only if the V0100 service is in the service code list. -->
	  <xsl:if test="request-param-list[@name='newServiceCodeList']/request-param-list-item/request-param[@name='serviceCode'][.='V0100']">
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_2</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
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
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">RELOCATION</xsl:element>
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
			<!-- Typ der Neuschaltung -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0133</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
                <xsl:element name="configured_value">Wechsel ohne Rufnummernübern.</xsl:element>
              </xsl:if> 
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernmitnahme'">
                <xsl:element name="configured_value">Wechsel mit Rufnummernübern.</xsl:element>
              </xsl:if>
            </xsl:element>   
			<!-- Neuer TNB -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0061</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
			<!-- ONKZ -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0124</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">  
			<!-- Get the area code from the access number and add a leading zero -->
			<xsl:value-of select="concat('0',substring-before(substring-after(request-param[@name='accessNumber'], ';'), ';'))"/>
              </xsl:element>
            </xsl:element>
			<!-- Auftragsvariante -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0810</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
                <xsl:element name="configured_value">Umzug ohne Rufnummernübernahme</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernmitnahme'">
                <xsl:element name="configured_value">Umzug mit Rufnummernübernahme</xsl:element>
              </xsl:if>
            </xsl:element>     
			<!-- Grund der Neukonfiguration -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">unbekannt</xsl:element>
            </xsl:element>    
			<!-- Bearbeitungsart -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>   
			<!-- Bemerkung -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:text>Umzug/</xsl:text>
                <xsl:value-of select="request-param[@name='relocationDate']"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="request-param[@name='userName']"/>
              </xsl:element>
            </xsl:element>    
			<!-- Aktivierungsdatum -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$relocationDateOPM"/>
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
			<!-- DTAG-Freitext -->
			<xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0141</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value"></xsl:element>
            </xsl:element>  
			<!-- Aktivierungszeit -->
			<xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0940</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">12</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>   
      
      <!-- Terminate Product Subscription -->
      <xsl:element name="CcmFifTerminateProductSubsCmd">
        <xsl:element name="command_id">terminate_ps_1</xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='relocationDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
          <xsl:element name="reason_rd">RELOCATION</xsl:element>
          <xsl:element name="auto_customer_order">N</xsl:element>
          <xsl:element name="detailed_reason_rd">
            <xsl:value-of select="request-param[@name='terminationReason']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>   
      
      <!-- look for a VoIP service in that bundle -->
      <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle_3</xsl:element>
          <xsl:element name="CcmFifFindBundleInCont">
            <xsl:element name="bundle_id_ref">
              <xsl:element name="command_id">find_bundle_1</xsl:element>
              <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>
            <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle_1</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element> 
        
         <!-- Find VoIP Service Subscription by bundled SS id, if a bundle was found -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_2</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_bundle_3</xsl:element>
              <xsl:element name="field_name">supported_object_id</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='relocationDate']"/>
            </xsl:element>                  
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle_3</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>           
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>  
        
        
		<xsl:if test="request-param[@name='terminateVoIP'] != 'Y'">  
		 <!-- Reconfigure VoIP Service Subscription -->
		 <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_2</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='relocationDate']"/>
            </xsl:element>            
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">RELOCATION</xsl:element>
            <xsl:element name="service_characteristic_list">
            
			<!-- Grund der Neukonfiguration -->
			<xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">VI008</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernmitnahme'">
                  <xsl:element name="configured_value">Umzug mit Rufnummernübernahme</xsl:element>
               </xsl:if>
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
                  <xsl:element name="configured_value">Umzug ohne Rufnummernübernahme</xsl:element>
              </xsl:if>     
            </xsl:element> 
            
			<!-- Bearbeitungsart -->
			<xsl:element name="CcmFifConfiguredValueCont">
                   <xsl:element name="service_char_code">VI002</xsl:element>
                   <xsl:element name="data_type">STRING</xsl:element>                
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernmitnahme'">
                    <xsl:element name="configured_value">NoOP</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='relocationType'] = 'Umzug ohne Rufnummernmitnahme'">
                    <xsl:element name="configured_value">OP</xsl:element>
              </xsl:if>  
            </xsl:element> 
            
			<!-- New location -->
			<xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_ref">
                <xsl:element name="command_id">create_addr_1</xsl:element>
                <xsl:element name="field_name">address_id</xsl:element>
              </xsl:element>
            </xsl:element>
            
			<!-- Aktivierungsdatum -->
			<xsl:element name="CcmFifConfiguredValueCont">
                   <xsl:element name="service_char_code">V0909</xsl:element>
                   <xsl:element name="data_type">STRING</xsl:element>
                   <xsl:element name="configured_value">
                     <xsl:value-of select="$relocationDateOPM"/>
                   </xsl:element>
            </xsl:element> 
            
			<!-- Neuer TNB -->
			<xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0061</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='carrier']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_3</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>           
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>    
        </xsl:element> 
        
		<!-- Create Customer Order for Reconfiguration -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_22</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="provider_tracking_no">001v</xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">reconf_serv_2</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_bundle_3</xsl:element>
                <xsl:element name="field_name">bundle_found</xsl:element>           
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>                
            </xsl:element>
          </xsl:element> 
          
		  <!-- Release Customer Order for Reconfiguration -->
		  <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="CcmFifReleaseCustOrderInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
              <xsl:element name="customer_order_ref">
                <xsl:element name="command_id">create_co_22</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_bundle_3</xsl:element>
                <xsl:element name="field_name">bundle_found</xsl:element>           
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>               
            </xsl:element>
          </xsl:element> 
            
        </xsl:if>   
        
			<xsl:if test="request-param[@name='terminateVoIP'] = 'Y'">
				<!--
                    TERMINATION OF VoIP PRODUCT
            -->
            
				<!-- Ensure that the termination has not been performed before -->
				<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
					<xsl:element name="command_id">find_cancel_stp_1</xsl:element>
					<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_service_2</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="reason_rd">TERMINATION</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- Reconfigure Service Subscription -->
				<xsl:element name="CcmFifReconfigServiceCmd">
					<xsl:element name="command_id">reconf_serv_12</xsl:element>
					<xsl:element name="CcmFifReconfigServiceInCont">
						<xsl:element name="service_subscription_ref">
							<xsl:element name="command_id">find_service_2</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">RELOCATION</xsl:element>
						<xsl:element name="service_characteristic_list">
							<!-- Kündigungsgrund -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0137</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='terminationReason']"/>
								</xsl:element>
							</xsl:element>
							<!-- Grund der Neukonfiguration -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI008</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
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
									<xsl:value-of select="$relocationDateOPM"/>
								</xsl:element>
							</xsl:element>
							<!-- Neuer TNB -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0061</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='carrier']"/>
								</xsl:element>
							</xsl:element>
							<!-- Backporting of VoIP Access Number 1 -->
							<xsl:if test="request-param[@name='portAccessNumber1'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0165</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber1']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 2 -->
							<xsl:if test="request-param[@name='portAccessNumber2'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0166</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber2']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 3 -->
							<xsl:if test="request-param[@name='portAccessNumber3'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0167</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber3']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 4 -->
							<xsl:if test="request-param[@name='portAccessNumber4'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0168</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber4']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 5 -->
							<xsl:if test="request-param[@name='portAccessNumber5'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0169</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber5']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 6 -->
							<xsl:if test="request-param[@name='portAccessNumber6'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0170</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber6']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 7 -->
							<xsl:if test="request-param[@name='portAccessNumber7'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0171</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber7']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 8 -->
							<xsl:if test="request-param[@name='portAccessNumber8'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0172</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber8']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 9 -->
							<xsl:if test="request-param[@name='portAccessNumber9'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0173</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber9']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Backporting of VoIP Access Number 10 -->
							<xsl:if test="request-param[@name='portAccessNumber10'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0174</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='portAccessNumber10']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				
				<!-- Terminate VoIP Product Subscription -->
				<xsl:element name="CcmFifTerminateProductSubsCmd">
					<xsl:element name="command_id">terminate_ps_12</xsl:element>
					<xsl:element name="CcmFifTerminateProductSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_service_2</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='relocationDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
						<xsl:element name="reason_rd">RELOCATION</xsl:element>
						<xsl:element name="auto_customer_order">N</xsl:element>
            <xsl:element name="detailed_reason_rd">
              <xsl:value-of select="request-param[@name='terminationReason']"/>
            </xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Create Customer Order for Reconfiguration -->
				<xsl:element name="CcmFifCreateCustOrderCmd">
					<xsl:element name="command_id">create_co_12</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="customer_tracking_id">
							<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
						</xsl:element>
						<xsl:element name="provider_tracking_no">001v</xsl:element>
						<xsl:element name="service_ticket_pos_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">reconf_serv_12</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				
				<!-- Create Customer Order for Termination -->
				<xsl:element name="CcmFifCreateCustOrderCmd">
					<xsl:element name="command_id">create_co_13</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="parent_customer_order_ref">
							<xsl:element name="command_id">create_co_12</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="customer_tracking_id">
							<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
						</xsl:element>
						<xsl:element name="provider_tracking_no">002v</xsl:element>
						<xsl:element name="service_ticket_pos_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">terminate_ps_12</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Release Customer Order for Reconfiguration -->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_12</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Release Customer Order for Termination -->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_13</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Create Contact for the termination of the VoIP service -->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="contact_type_rd">AUTO_RELOCATION</xsl:element>
						<xsl:element name="short_description">Automatischer Umzug</xsl:element>
						<xsl:element name="description_text_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:text>&#xA;ContractNumber: </xsl:text>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_service_2</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>&#xA;serviceSubscriptionId: </xsl:text>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_service_2</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
   		
      <!-- Create Customer Order for Reconfiguration -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_3</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>           
          </xsl:element>
        </xsl:element>
      </xsl:element>   

      <!-- Create Customer Order for Termination -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_4</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="parent_customer_order_ref">
            <xsl:element name="command_id">create_co_3</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">002</xsl:element>
          <xsl:element name="service_ticket_pos_list_ref">
            <xsl:element name="command_id">terminate_ps_1</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>  

      <!-- Release Customer Order for Reconfiguration -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_3</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>    

      <!-- Release Customer Order for Termination -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_4</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>   

      <!-- Create Contact for the Service relocation -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_RELOCATION</xsl:element>
          <xsl:element name="short_description">Automatischer Umzug</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;ContractNumber: </xsl:text>
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>  

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
