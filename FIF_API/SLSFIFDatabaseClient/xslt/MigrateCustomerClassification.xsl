<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for migrating the customer classifications

  @author schwarje
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
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

	<!-- Modify Contact Role -->
    <xsl:element name="CcmFifModifyContactRoleCmd">
      <xsl:element name="CcmFifModifyContactRoleInCont">
        <xsl:element name="customer_number_list">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="salutation_old">
          <xsl:value-of select="request-param[@name='SALUTATION_OLD']"/>
        </xsl:element>
        <xsl:element name="name_old">
          <xsl:value-of select="request-param[@name='NAME_OLD']"/>
        </xsl:element>
        <xsl:element name="forename_old">
          <xsl:value-of select="request-param[@name='FORENAME_OLD']"/>
        </xsl:element>
        <xsl:element name="deactivation">
          <xsl:value-of select="request-param[@name='DEACTIVATION']"/>
        </xsl:element>
        <xsl:element name="salutation_new">
          <xsl:value-of select="request-param[@name='SALUTATION_NEW']"/>
        </xsl:element>
        <xsl:element name="name_new">
          <xsl:value-of select="request-param[@name='NAME_NEW']"/>
        </xsl:element>
        <xsl:element name="forename_new">
          <xsl:value-of select="request-param[@name='FORENAME_NEW']"/>
        </xsl:element>
        <xsl:element name="desired_date"></xsl:element>
        <xsl:element name="contact_role_type_rd">ARCOR</xsl:element>
        <xsl:element name="supported_object_type_rd">CUSTOMER</xsl:element>
      </xsl:element>
    </xsl:element>

	<!-- Change Customer -->
    <xsl:element name="CcmFifChangeCustomerCmd">
      <xsl:element name="CcmFifChangeCustomerInCont">
        <xsl:element name="customer_number">
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
        </xsl:element>
        <xsl:element name="category_rd">
          <xsl:value-of select="request-param[@name='CATEGORY_RD']"/>
        </xsl:element>
        <xsl:element name="classification_rd">
          <xsl:value-of select="request-param[@name='CLASSIFICATION_RD']"/>
        </xsl:element>
        <xsl:element name="customer_group_rd">
          <xsl:value-of select="request-param[@name='CUSTOMER_GROUP_RD']"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
   </xsl:element>

  </xsl:template>
</xsl:stylesheet>
