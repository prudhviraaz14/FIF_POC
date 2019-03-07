<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  
  @author schwarje
-->
<xsl:stylesheet version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="request-params">
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    
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
            
      <xsl:variable name="barcode">
        <xsl:choose>
          <xsl:when test="starts-with(request-param[@name='OMTS_ORDER_ID'], 'ARC')">
            <xsl:text>WIT</xsl:text>
            <xsl:value-of select="substring-after(request-param[@name='OMTS_ORDER_ID'], 'ARC')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Terminate simple services & cancels ordered ones -->
      <xsl:element name="CcmFifTerminateServicesSOMCmd">
        <xsl:element name="command_id">term_simple_services_1</xsl:element>
        <xsl:element name="CcmFifTerminateServicesSOMInCont">
          <xsl:element name="service_subscription_list">
            <xsl:for-each select="request-param-list[@name='SERVICE_SUBSCRIPTION_LIST']/request-param-list-item">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
          <xsl:element name="termination_reason_rd">
            <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="$barcode" />
          </xsl:element> 
         </xsl:element>
      </xsl:element>
            
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
          <xsl:element name="short_description">WITA-Migration</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Migration einer Kündigung auf WITA</xsl:text>
            <xsl:text>&#xA;Alter Auftrag: </xsl:text>
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
            <xsl:text>&#xA;Neuer Auftrag: </xsl:text>
            <xsl:value-of select="$barcode"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
