<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations
  
  @author banania
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
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

   <!--  Validate TRANSACTION_CODE  --> 

    <xsl:if test="request-param[@name='ID'] != '' and request-param[@name='ID'] != 'A' and request-param[@name='ID'] != 'D'">
    <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raise_warning</xsl:element> 
        <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for action to perform: 'A' or 'D'.</xsl:element>
            <xsl:element name="log_warning">Y</xsl:element>
        </xsl:element>
    </xsl:element>
    </xsl:if>

    <xsl:variable name="TransactionCode">  
      <xsl:choose>
        <xsl:when test="request-param[@name='ID'] != ''">
          <xsl:value-of select="request-param[@name='ID']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="request-param[@name='TRANSACTION_CODE']"/>
        </xsl:otherwise>
      </xsl:choose>                      
    </xsl:variable>
    
    <xsl:variable name="DiscountGroupType">
    	<xsl:choose>
    	<xsl:when test="request-param[@name='DISCOUNT_GROUP_TYPE'] != ''">
    	   <xsl:value-of select="request-param[@name='DISCOUNT_GROUP_TYPE']"/>
    	</xsl:when>
    	<xsl:otherwise>CorporateGroup</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
   
    <xsl:if test="($TransactionCode != 'N') and ($TransactionCode != 'D') and ($TransactionCode != 'A')">
    <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raise_warning</xsl:element> 
        <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for action to perform: 'N' or 'D'.</xsl:element>
            <xsl:element name="log_warning">Y</xsl:element>
        </xsl:element>
    </xsl:element>
    </xsl:if>
        
      <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
      <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($Today, 'DATE', '1')"/>      
      
      <xsl:variable name="BeginNumber">  
        <xsl:choose>
          <xsl:when test="request-param[@name='RN'] != ''">
            <xsl:if test="starts-with((request-param[@name='RN']),'49') = false">
               <xsl:text>49</xsl:text>
            </xsl:if>
            <xsl:value-of select="request-param[@name='RN']"/>
          </xsl:when>
          <xsl:when test ="request-param[@name='BEGIN_NUMBER'] != 'GSMMSISDN'">
            <xsl:text>49</xsl:text>
            <xsl:value-of select="substring-after(request-param[@name='BEGIN_NUMBER'], 'GSM')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-after(request-param[@name='BEGIN_NUMBER'], 'GSM')"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <!-- Validate BEGIN_NUMBER  -->  
      <xsl:if
        test="starts-with((request-param[@name='BEGIN_NUMBER']),'GSM') = false and request-param[@name='BEGIN_NUMBER'] != ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">BEGIN_NUMBER must start with 'GSM'.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 

      <xsl:if test="$TransactionCode = 'D'
        or $TransactionCode = 'N' or $TransactionCode = 'A'"> 
        <!-- Delete first DEACT discount groups -->
        <xsl:element name="CcmFifRemoveDeactDiscountGroupRowCmd">
          <xsl:element name="command_id">remove_dg_1</xsl:element>
          <xsl:element name="CcmFifRemoveDeactDiscountGroupRowInCont">
            <xsl:element name="group_id">
              <xsl:value-of select="request-param[@name='GROUP_ID']"/>
            </xsl:element>
            <xsl:element name="begin_number">
              <xsl:value-of select="$BeginNumber"/>
            </xsl:element>        
          </xsl:element>
        </xsl:element>
		
	  <xsl:if test="$TransactionCode != 'D'"> 
      <!-- fCreate the DISCOUNT GROUP -->
      <xsl:element name="CcmFifCreateDiscountGroupCmd">
        <xsl:element name="command_id">create_dg_1</xsl:element>
        <xsl:element name="CcmFifCreateDiscountGroupInCont">
          <xsl:element name="group_id">
            <xsl:value-of select="request-param[@name='GROUP_ID']"/>
          </xsl:element>
          <xsl:element name="begin_number">
            <xsl:value-of select="$BeginNumber"/>
          </xsl:element>        
          <xsl:element name="discount_group_type_rd">
             <xsl:value-of select="$DiscountGroupType"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if> 
      </xsl:if>
      <xsl:if test="$TransactionCode = 'D'
        and $BeginNumber != 'MSISDN'"> 
        
         <!-- Deactivate Selected destinations -->      
          <xsl:element name="CcmFifDeactSelectedDestForDGCmd">
            <xsl:element name="command_id">deact_sd_by_dg_1</xsl:element>
            <xsl:element name="CcmFifDeactSelectedDestForDGInCont">
              <xsl:element name="group_id">
                <xsl:value-of select="request-param[@name='GROUP_ID']"/>
              </xsl:element>
              <xsl:element name="begin_number">
                <xsl:value-of select="$BeginNumber"/>
              </xsl:element>              
              <xsl:element name="effective_date">
                <xsl:value-of select="$tomorrow"/>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
            
          <!-- Deactivate discount group - all selected destinations are deactivated-->
          <xsl:element name="CcmFifDeactDiscountGroupCmd">
            <xsl:element name="command_id">create_dg_1</xsl:element>
            <xsl:element name="CcmFifDeactDiscountGroupInCont">
              <xsl:element name="group_id">
                <xsl:value-of select="request-param[@name='GROUP_ID']"/>
              </xsl:element>
              <xsl:element name="begin_number">
                <xsl:value-of select="$BeginNumber"/>
              </xsl:element>         
              <xsl:element name="effective_date">
                <xsl:value-of select="$tomorrow"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>            
       
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
