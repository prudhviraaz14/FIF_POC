<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Modify Contract FIF request

  @author goethalo
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction_list.dtd"/>

  <xsl:template match="/">
    <xsl:element name="CcmFifTransactionList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">

  <xsl:element name="transaction_list_id">123</xsl:element>
  <xsl:element name="transaction_list_name">123</xsl:element>
  <xsl:element name="transaction_list">
  <xsl:element name="CcmFifCommandList">
    <xsl:element name="transaction_id">238423478234</xsl:element>
    <xsl:element name="client_name">TF</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="request-param[@name='previousAction']"/>
    </xsl:element>
    <xsl:element name="Command_List">

    <xsl:element name="CcmFifPassBackValueCmd">
      <xsl:element name="command_id">dummy</xsl:element>
      <xsl:element name="CcmFifPassBackValueInCont">
        <xsl:element name="parameter_value_list">
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">newPricingStructureCode</xsl:element>
            <xsl:element name="parameter_value">123</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:element>
  </xsl:element>

    <xsl:element name="CcmFifCommandList">

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
      <xsl:if test="request-param[@name='newPricingStructureCode'] != ''">
        <!-- Add PassBack containers -->
        <xsl:element name="CcmFifPassBackValueCmd">
          <xsl:element name="command_id">passback_1</xsl:element>
          <xsl:element name="CcmFifPassBackValueInCont">
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">newPricingStructureCode</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Renegotiate Order Form  -->
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <!-- Change the mimimum period, if needed -->
          <xsl:if test="request-param[@name='changeMinimumDuration'] = 'Y'">
            <xsl:element name="min_per_dur_value">
              <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
            </xsl:element>
            <xsl:element name="min_per_dur_unit">
              <xsl:value-of select="request-param[@name='newMinPeriodDurationUnit']"/>
            </xsl:element>
            <xsl:element name="term_start_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="override_restriction">
            <xsl:value-of select="request-param[@name='overrideRestriction']"/>
          </xsl:element>
          <!-- Change the tariff, if needed -->
          <xsl:if test="request-param[@name='changeTariff'] = 'Y'">
            <xsl:element name="product_commit_list">
              <xsl:element name="CcmFifProductCommitCont">
                <xsl:element name="new_pricing_structure_code">
                  <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="auto_extent_period_value">
            <xsl:value-of select="request-param[@name='newAutoExtentPeriodValue']"/>
          </xsl:element>                         
          <xsl:element name="auto_extent_period_unit">
            <xsl:value-of select="request-param[@name='newAutoExtentPeriodUnit']"/>
          </xsl:element>                         
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='newAutoExtensionInd']"/>
          </xsl:element>                         
        </xsl:element>
      </xsl:element>

      <!-- check for a bandwidth change -->
      <xsl:element name="CcmFifValidatePreviousActionCmd">
        <xsl:element name="command_id">validate_previous_action_1</xsl:element>
        <xsl:element name="CcmFifValidatePreviousActionInCont">
          <xsl:element name="action_name">changeDSLBandwidth</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- get the owning customer for the contract -->
      <xsl:element name="CcmFifGetOwningCustomerCmd">
        <xsl:element name="command_id">get_owning_customer_1</xsl:element>
        <xsl:element name="CcmFifGetOwningCustomerInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- look for a voice-online bundle -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_owning_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_type_rd">VOICE_ONLINE</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_previous_action_1</xsl:element>
            <xsl:element name="field_name">action_performed_ind</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- look for a voice service in that bundle -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_2</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>      

      <!-- find customer order -->
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_customer_order_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_bundle_2</xsl:element>
            <xsl:element name="field_name">supported_object_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">CHANGE_BANDWIDTH</xsl:element>
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
          <xsl:element name="allow_children">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Sign Order Form And Apply New Pricing Structure
      	   dependent apply is used, if an open customer order is found -->
      <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
        <xsl:element name="command_id">sign_apply_1</xsl:element>
        <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="apply_swap_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="board_sign_name">ARCOR</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
      <!-- Create KBA notification, if the request is not a KBA request -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>                
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='customerNumber']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">CONTACT</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CATEGORY</xsl:element>
              <xsl:element name="parameter_value">Tariff</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='clientName']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">WORK_DATE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>Tarifwechsel/Vertragsänderung über </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>.</xsl:text>
				<xsl:if test="request-param[@name='newPricingStructureCode'] != ''">
				  <xsl:text>  Neuer Tarif: </xsl:text>
				  <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
				  <xsl:text>.</xsl:text>
				</xsl:if>
				<xsl:if test="request-param[@name='changeMinimumDuration'] = 'Y'">
				  <xsl:text>  Neue Vertragslaufzeit: </xsl:text>
				  <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
				  <xsl:text>.</xsl:text>
				</xsl:if>						
              </xsl:element>
            </xsl:element>
          </xsl:element>     
        </xsl:element>
      </xsl:element>
      </xsl:if>

    </xsl:element>
  </xsl:element>
  </xsl:element>
  </xsl:template>
</xsl:stylesheet>
