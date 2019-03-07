<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a terminate product subscription FIF request

  @author goethalo
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
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
        
      <!-- Lock product subscription  -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
			<xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
		  </xsl:element>
          <xsl:element name="object_type">PROD_SUBS</xsl:element>
        </xsl:element>
      </xsl:element>   
    
      <!-- Terminate Order Form -->
      <xsl:element name="CcmFifTerminateProductSubsCmd">
        <xsl:element name="command_id">terminate_ps_1</xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:if>            
            <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
              <!-- Get today's date -->
              <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
              <xsl:value-of select="$today"/>
            </xsl:if>                          
          </xsl:element>                
          <xsl:element name="desired_schedule_type">
            <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
          <xsl:element name="auto_customer_order">
            <xsl:value-of select="request-param[@name='AUTO_CUSTOMER_ORDER']"/>
          </xsl:element>
          <xsl:element name="detailed_reason_rd">
            <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
