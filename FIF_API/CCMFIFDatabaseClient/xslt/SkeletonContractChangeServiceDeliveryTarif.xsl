<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an apply new pricing structure FIF request

  @author goethalo
-->
<xsl:stylesheet version="1.0"
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
    <xsl:element name="client_name">CCM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Generate Barcode -->     
      <xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
        <xsl:element name="command_id">generate_barcode_1</xsl:element>
      </xsl:element> 
      
      
      <!-- Renegotiate Order Form  -->
      <xsl:element name="CcmFifRenegotiateSDCProductCommitmentCmd">
        <xsl:element name="command_id">renegotiate_sdc_prod_comm_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateSDCProductCommitmentInCont">
          <xsl:element name="product_commitment_number">
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="override_restriction">Y</xsl:element>               
          <xsl:element name="product_commit_list">
            <!-- Pass in the list of Product/Pricing Structure Codes -->
            <xsl:for-each select="request-param-list[@name='FIF_PRODUCT_COMMIT_LIST']/request-param-list-item">
                <xsl:element name="CcmFifProductCommitCont">
                    <xsl:element name="old_product_code">
                        <xsl:value-of select="request-param[@name='OLD_PRODUCT_CODE']"/>
                    </xsl:element>    
                    <xsl:element name="old_pricing_structure_code">
                        <xsl:value-of select="request-param[@name='OLD_PRICING_STRUCT_CODE']"/>
                    </xsl:element>    
                    <xsl:element name="new_product_code">
                        <xsl:value-of select="request-param[@name='NEW_PRODUCT_CODE']"/>
                    </xsl:element>    
                    <xsl:element name="new_pricing_structure_code">
                        <xsl:value-of select="request-param[@name='NEW_PRICING_STRUCT_CODE']"/>
                    </xsl:element>    
                    <xsl:element name="min_per_dur_value">
                      <xsl:value-of select="request-param[@name='MIN_PERIOD_DUR_VALUE']"/>
                    </xsl:element>     
                    <xsl:element name="min_per_dur_unit">
                      <xsl:value-of select="request-param[@name='MIN_PERIOD_DUR_UNIT']"/>
                    </xsl:element>     
                </xsl:element>
            </xsl:for-each>
          </xsl:element>
          <xsl:element name="customer_tracking_id_ref">
            <xsl:element name="command_id">generate_barcode_1</xsl:element>
            <xsl:element name="field_name">customer_tracking_id</xsl:element>
          </xsl:element>
          
          
        </xsl:element>
      </xsl:element> 
      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignSDCProductCommitmentCmd">
        <xsl:element name="command_id">sign_sdc_prod_comm_1</xsl:element>
        <xsl:element name="CcmFifSignSDCProductCommitmentInCont">
          <xsl:element name="product_commitment_number">
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="board_sign_name">ARCOR</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Apply New Pricing Structure -->
      <xsl:element name="CcmFifApplyNewPricingStructCmd">
        <xsl:element name="command_id">apply_new_ps_1</xsl:element>
        <xsl:element name="CcmFifApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">S</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">CONTRACT</xsl:element>
          <xsl:element name="short_description">Skeleton Contract Propagation</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>The product commitment  </xsl:text>
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
            <xsl:text> was renegotiated due to the </xsl:text>
            <xsl:text>renegotiation of the corresponding skeleton contract</xsl:text>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
