<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Modify Address FIF request

  @author makuier
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

      <xsl:variable name="DesiredDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='desiredDate'] = ''">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <xsl:if test="request-param[@name='clientName'] = 'SLS'">              
        <!-- Get Address Data -->
        <xsl:element name="CcmFifGetAddressDataCmd">
          <xsl:element name="command_id">get_address_data</xsl:element>
          <xsl:element name="CcmFifGetAddressDataInCont">
            <xsl:element name="address_id">
              <xsl:value-of select="request-param[@name='addressId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
        <!-- Validate Address Type --> 
        <xsl:element name="CcmFifValidateValueCmd">
          <xsl:element name="command_id">validate_value_1</xsl:element>
          <xsl:element name="CcmFifValidateValueInCont">
            <xsl:element name="value_ref">
              <xsl:element name="command_id">get_address_data</xsl:element>
              <xsl:element name="field_name">address_type_rd</xsl:element>
            </xsl:element>
            <xsl:element name="object_type">ADDRESS</xsl:element>
            <xsl:element name="value_type">ADDRESS_TYPE_RD</xsl:element>
            <xsl:element name="allowed_values">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">KUND</xsl:element>
              </xsl:element> 
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">STD</xsl:element>
              </xsl:element>          
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>    
          
      <!-- Modify Address -->
      <xsl:element name="CcmFifModifyAddressCmd">
        <xsl:element name="command_id">modify_address_1</xsl:element>
        <xsl:element name="CcmFifModifyAddressInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="address_id">
            <xsl:value-of select="request-param[@name='addressId']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='addressType'] != ''">          
            <xsl:element name="address_type">
              <xsl:value-of select="request-param[@name='addressType']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="add_address_desc">
            <xsl:value-of select="request-param[@name='addAddressDesc']"/>
          </xsl:element>
          <xsl:element name="second_add_address_desc">
            <xsl:value-of select="request-param[@name='secondAddAddressDesc']"/>
          </xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='streetName']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='streetNumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='streetNumberSuffix']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='postalCode']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='cityName']"/>
          </xsl:element>
          <xsl:element name="city_suffix_name">
            <xsl:value-of select="request-param[@name='citySuffixName']"/>
          </xsl:element>
	  <xsl:if test="request-param[@name='country'] != ''">
          <xsl:element name="country">
            <xsl:value-of select="request-param[@name='country']"/>
          </xsl:element>
	  </xsl:if>
	  <xsl:if test="request-param[@name='country'] = ''">
	  	<xsl:element name="country">DE</xsl:element>
	  </xsl:if>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
