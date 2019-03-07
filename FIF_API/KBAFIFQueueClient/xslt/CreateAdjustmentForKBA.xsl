<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Create Adjustment for KBA FIF requests

  @author goethalo
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
    
      <xsl:variable name="ReasonCode">
          <xsl:value-of select="request-param[@name='reasonCode']"/>
      </xsl:variable> 
            
      <xsl:variable name="DescriptionText">  
        <xsl:choose>
          <xsl:when test ="$ReasonCode = '340ZWVS' and 
            request-param[@name='descriptionText'] = ''">
            <xsl:text>Versand von Rechnungszweitschriften</xsl:text>
          </xsl:when>
          <xsl:when test ="$ReasonCode = 'GUT_HARD'and 
            request-param[@name='descriptionText'] = ''">
            <xsl:text>Gutschrift Hardware</xsl:text>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="request-param[@name='descriptionText']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable> 

      <xsl:variable name="InternalReasonText">  
        <xsl:choose>
          <xsl:when test ="$ReasonCode = '340ZWVS' and 
            request-param[@name='descriptionText'] = ''">
            <xsl:text>System. LS (nicht man. ausw.)</xsl:text>
          </xsl:when>
          <xsl:when test ="$ReasonCode = 'GUT_HARD' and 
            request-param[@name='descriptionText'] = ''">
            <xsl:text>Credit Hardware</xsl:text>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="request-param[@name='internalReasonText']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable> 
              
      <!-- check, if the adjustment is a debit adjustment, otherwise raise an error, as
        the resolution user id is required in this case -->
      <xsl:if test="request-param[@name='resolutionUserId'] = ''">
        <xsl:element name="CcmFifGetGeneralCodeGroupCmd">
          <xsl:element name="command_id">check_debit_adjustment</xsl:element>
          <xsl:element name="CcmFifGetGeneralCodeGroupInCont">
            <xsl:element name="value">
              <xsl:value-of select="request-param[@name='reasonCode']"/>
            </xsl:element>
            <xsl:element name="group_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">ADJDEBIT</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''                              
        and request-param[@name='recurringValue'] != ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_adjustment_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">For recurring adjustments the parameter 'serviceSubscriptionId' can not be empty!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
  
      <xsl:if test="request-param[@name='paymentMode'] != ''                              
        and request-param[@name='paymentMode'] != 'INVOICE'
        and request-param[@name='paymentMode'] != 'DIRECT'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_adjustment_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for the parameter paymentmode: INVOICE or DIRECT.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
          
      <!-- Create Adjustment -->
      <xsl:element name="CcmFifCreateAdjustmentCmd">
        <xsl:element name="command_id">create_adjustment_1</xsl:element>
        <xsl:element name="CcmFifCreateAdjustmentInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element>
          <xsl:element name="start_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="base_currency_amount">
            <xsl:value-of select="request-param[@name='adjustmentAmount']"/>
          </xsl:element>
          <xsl:element name="create_user_id">
            <xsl:value-of select="request-param[@name='userName']"/>
          </xsl:element>
          <xsl:element name="description_text">
            <xsl:value-of select="$DescriptionText"/>
          </xsl:element>
          <xsl:element name="reason_code">
            <xsl:value-of select="$ReasonCode"/>
          </xsl:element>
          <xsl:if test="request-param[@name='reasonCode'] != '115TECE'">
            <xsl:element name="product_code">
              <xsl:value-of select="request-param[@name='productCode']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='reasonCode'] = '115TECE'">
            <xsl:element name="product_code">Z0101</xsl:element>
          </xsl:if>
          <xsl:element name="tax_code">
            <xsl:value-of select="request-param[@name='taxCode']"/>
          </xsl:element>
          <xsl:element name="internal_reason_text">
            <xsl:value-of select="$InternalReasonText"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganizationNumber']"/>
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>
          <xsl:element name="create_date">
            <xsl:value-of select="request-param[@name='createDate']"/>
          </xsl:element>
          <xsl:element name="resolution_date">
            <xsl:value-of select="request-param[@name='resolutionDate']"/>
          </xsl:element>
          <xsl:element name="resolution_user_id">
            <xsl:if test="request-param[@name='resolutionUserId'] != ''">
              <xsl:value-of select="request-param[@name='resolutionUserId']"/>
            </xsl:if>
            <xsl:if test="request-param[@name='resolutionUserId'] = ''">
              <xsl:value-of select="request-param[@name='userName']"/>
            </xsl:if>
          </xsl:element>
          <xsl:if test="(request-param[@name='serviceSubscriptionId'] != '')">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if
            test="(request-param[@name='serviceSubscriptionId'] = '')
		  	and (request-param[@name='serviceTicketPositionId'] != '')">
            <xsl:element name="service_ticket_position_id">
              <xsl:value-of select="request-param[@name='serviceTicketPositionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if
            test="(request-param[@name='serviceSubscriptionId'] = '')
		  	and (request-param[@name='serviceTicketPositionId'] = '')
			and (request-param[@name='productSubscriptionId'] != '')">
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if
            test="(request-param[@name='serviceSubscriptionId'] = '')
		  	and (request-param[@name='serviceTicketPositionId'] = '')
			and (request-param[@name='productSubscriptionId'] = '')
			and (request-param[@name='childCustomerNumber'] != '')">
            <xsl:element name="child_customer_number">
              <xsl:value-of select="request-param[@name='childCustomerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element> 
          <xsl:element name="recurring_duration">
            <xsl:value-of select="request-param[@name='recurringValue']"/>
          </xsl:element>   
          <xsl:element name="payment_mode">
            <xsl:value-of select="request-param[@name='paymentMode']"/>
          </xsl:element> 
          <xsl:element name="kba_transaction_nr">
            <xsl:value-of select="request-param[@name='KBATransactionNr']"/>
          </xsl:element> 
          <xsl:element name="print">
            <xsl:value-of select="request-param[@name='print']"/>
          </xsl:element> 
        </xsl:element>
      </xsl:element>

      <!-- get customer data to retrieve customer category-->
      <xsl:element name="CcmFifGetCustomerDataCmd">
        <xsl:element name="command_id">get_customer_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerDataInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_adjustment_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="no_customer_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact-->

      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact_1</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_adjustment_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">ADJUSTMENT</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='userName']"/>
          </xsl:element>
          <xsl:element name="short_description">Add Adjustment.</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:value-of select="$InternalReasonText"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_customer_data</xsl:element>
            <xsl:element name="field_name">state_rd</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">ACTIVATED</xsl:element> 
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
