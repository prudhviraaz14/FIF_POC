  <!-- For SLS only!! -->
<xsl:if test="request-param[@name='HDServiceCode1'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_1_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
        <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="service_code">
          <xsl:value-of select="request-param[@name='HDServiceCode1']"/>                
        </xsl:element>
        <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
        </xsl:element> 
        <xsl:element name="desired_schedule_type">ASAP</xsl:element>
        <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
        </xsl:element>
        <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
        </xsl:element>
        <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode2'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_2_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode2']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode3'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_3_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode3']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode4'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_4_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode4']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode5'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_5_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode5']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode6'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_6_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode6']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode7'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_7_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode7']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode8'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_8_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode8']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode9'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_9_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode9']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode10'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_10_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode10']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode11'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_11_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode11']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode12'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_12_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode12']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<!-- For SLS only!! -->
<xsl:if test="request-param[@name='HDServiceCode13'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_13_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode13']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode14'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_14_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode14']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<xsl:if test="request-param[@name='HDServiceCode15'] != ''">	
  <xsl:element name="CcmFifAddServiceSubsCmd">
    <xsl:element name="command_id">add_hd_15_service</xsl:element>
    <xsl:element name="CcmFifAddServiceSubsInCont">
      <xsl:element name="product_subscription_ref">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="field_name">product_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="service_code">
        <xsl:value-of select="request-param[@name='HDServiceCode15']"/>                
      </xsl:element>
      <xsl:element name="parent_service_subs_ref">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="desired_date">
        <xsl:value-of select="$today"/>	
      </xsl:element> 
      <xsl:element name="desired_schedule_type">ASAP</xsl:element>
      <xsl:element name="reason_rd">
        <xsl:value-of select="$ReasonRd"/>
      </xsl:element>
      <xsl:element name="account_number">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:element>
      <xsl:element name="service_characteristic_list"/>
    </xsl:element>
  </xsl:element>
</xsl:if>

<!-- Add STPs to customer order if exists -->   
<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
  <xsl:element name="command_id">add_stp_to_co</xsl:element>
  <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
    <xsl:element name="customer_order_id_ref">
      <xsl:element name="command_id">create_co_1</xsl:element>
      <xsl:element name="field_name">customer_order_id</xsl:element>
    </xsl:element>
    <xsl:element name="service_ticket_pos_list">
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_1_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_2_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_3_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_4_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_5_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_6_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_7_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_8_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_9_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_10_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_11_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_12_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_13_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_14_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
      <xsl:element name="CcmFifCommandRefCont">
        <xsl:element name="command_id">add_hd_15_service</xsl:element>
        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
      </xsl:element> 
    </xsl:element>
    <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
    <xsl:element name="processing_status">
      <xsl:value-of select="request-param[@name='processingStatus']"/>
    </xsl:element>
  </xsl:element>
</xsl:element>
