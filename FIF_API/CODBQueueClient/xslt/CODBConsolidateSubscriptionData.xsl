<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for triggering the automatic data reconciliation

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      <xsl:variable name="dueDate">
        <xsl:value-of select="dateutils:createFIFDateOffset($today, 'DATE', request-param[@name='delay'])"/>
      </xsl:variable>
      
      <xsl:if test="request-param[@name='customerIntention'] != ''">
     	<xsl:element name="CcmFifValidateGeneralCodeItemCmd">
			<xsl:element name="command_id">blockReconciliation</xsl:element>
			<xsl:element name="CcmFifValidateGeneralCodeItemInCont">
				<xsl:element name="group_code">CUSTINTREC</xsl:element>
				<xsl:element name="value">
					<xsl:value-of select="request-param[@name='customerIntention']"/>
				</xsl:element>
				<xsl:element name="raise_error_if_invalid">N</xsl:element>
			</xsl:element>
		</xsl:element>      
      </xsl:if>
      
      <xsl:element name="CcmFifCreateFifRequestCmd">
        <xsl:element name="command_id">create_fif_request</xsl:element>
        <xsl:element name="CcmFifCreateFifRequestInCont">
          <xsl:element name="action_name">consolidateSubscriptionData</xsl:element>
          <xsl:element name="due_date">
            <xsl:value-of select="$dueDate"/>
          </xsl:element>
          <xsl:element name="dependent_transaction_id">dummy</xsl:element>          
          <xsl:element name="priority">5</xsl:element>
          <xsl:element name="bypass_command">N</xsl:element>
          <xsl:element name="external_system_id">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='orderId']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
          </xsl:element>
          <xsl:element name="request_param_list">
            <!--
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">bundleID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_bundle</xsl:element>
                <xsl:element name="field_name">bundle_id</xsl:element>
              </xsl:element>
            </xsl:element>
            -->
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">bundleId</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='bundleId']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">orderId</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='orderId']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">orderPositionNumber</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">customerNumber</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
            </xsl:element>            
          </xsl:element>
		  <xsl:if test="request-param[@name='customerIntention'] != ''">
			<xsl:element name="process_ind_ref">
			  <xsl:element name="command_id">blockReconciliation</xsl:element>
			  <xsl:element name="field_name">is_valid</xsl:element>
			</xsl:element>
			<xsl:element name="required_process_ind">N</xsl:element>
		  </xsl:if>
        </xsl:element>
      </xsl:element>
      

      </xsl:element>
  </xsl:template>
</xsl:stylesheet>
