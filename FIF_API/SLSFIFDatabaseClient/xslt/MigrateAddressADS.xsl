<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
  XSLT file for address migration processed by ADS 

  @author Naveen
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" exclude-result-prefixes="dateutils" version="1.0">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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
		
    <xsl:element name="Command_List">
    
    <xsl:variable name="addressId">
       <xsl:choose>
    	  <xsl:when test ="request-param[@name='CCB_Address-ID'] != ''">
    	     <xsl:value-of select="request-param[@name='CCB_Address-ID']"/>
          </xsl:when>
    	  <xsl:otherwise>
		     <xsl:value-of select ="request-param[@name='addressId']"/>
		  </xsl:otherwise>
       </xsl:choose>
	</xsl:variable>
		 
	<xsl:variable name="streetName">
    	<xsl:choose>
    	   <xsl:when test ="request-param[@name='Strassenname'] != ''">
		  	  <xsl:value-of select ="request-param[@name='Strassenname']"/>
		   </xsl:when>
		   <xsl:otherwise>
              <xsl:value-of select="request-param[@name='streetName']"/>
           </xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
		 
	<xsl:variable name="streetNumber">
    	<xsl:choose>
    	   <xsl:when test ="request-param[@name='Hausnr.'] != ''">
		  	  <xsl:value-of select ="request-param[@name='Hausnr.']"/>
		   </xsl:when>
		   <xsl:otherwise>
              <xsl:value-of select="request-param[@name='streetNumber']"/>
           </xsl:otherwise>
		 </xsl:choose>
	</xsl:variable>
		 
	<xsl:variable name="postOfficeBox">
    	<xsl:choose>
    	   <xsl:when test ="request-param[@name='Postfachnr'] != ''">
		  	  <xsl:value-of select ="request-param[@name='Postfachnr']"/>
		  </xsl:when>
		  <xsl:otherwise>
             <xsl:value-of select="request-param[@name='postOfficeBox']"/>
         </xsl:otherwise>
	   </xsl:choose>
   </xsl:variable>
		 
   <xsl:variable name="PostalCode">
       <xsl:choose>
    	  <xsl:when test ="request-param[@name='PLZ'] != ''">
		  	  <xsl:value-of select ="request-param[@name='PLZ']"/>
		  </xsl:when>
		  <xsl:otherwise>
              <xsl:value-of select="request-param[@name='postalCode']"/>
          </xsl:otherwise>
	  </xsl:choose>
   </xsl:variable>
		 
   <xsl:variable name="cityName">
      <xsl:choose>
    	  <xsl:when test ="request-param[@name='Ortsname'] != ''">
		  	 <xsl:value-of select ="request-param[@name='Ortsname']"/>
		  </xsl:when>
		  <xsl:otherwise>
              <xsl:value-of select="request-param[@name='cityName']"/>
         </xsl:otherwise>
	   </xsl:choose>
   </xsl:variable>
		 
		 <xsl:variable name="citySuffix">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='Ortszusatz'] != ''">
		  	<xsl:value-of select ="request-param[@name='Ortszusatz']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='citySuffix']"/>
         </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		 <xsl:variable name="countryCode">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='Landerkennung'] != ''">
		  	<xsl:value-of select ="request-param[@name='Landerkennung']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='countryCode']"/>
         </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		 <xsl:variable name="addressConfirmed">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='bestatigt'] != ''">
		  	<xsl:value-of select ="request-param[@name='bestatigt']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='addressConfirmed']"/>
         </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		 <xsl:variable name="adsAddressId">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='neue_Adress-ID'] != ''">
		  	<xsl:value-of select ="request-param[@name='neue_Adress-ID']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='adsAddressId']"/>
       </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		 <xsl:variable name="district">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='Ortsteil'] != ''">
		  	<xsl:value-of select ="request-param[@name='Ortsteil']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='district']"/>
         </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		  <xsl:variable name="numberSuffix">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='Hausnr.-Zusatz'] != ''">
		  	<xsl:value-of select ="request-param[@name='Hausnr.-Zusatz']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='numberSuffix']"/>
         </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		 <xsl:variable name="effectiveDate">
    	<xsl:choose>
    	<xsl:when test ="request-param[@name='CCB_effDate'] != ''">
		  	<xsl:value-of select ="request-param[@name='CCB_effDate']"/>
		  </xsl:when>
		 <xsl:otherwise>
            <xsl:value-of select="request-param[@name='effectiveDate']"/>
         </xsl:otherwise>
		 </xsl:choose>
		 </xsl:variable>
		 
		<xsl:element name ="CcmFifValidateValueCmd">
   		<xsl:element name ="command_id">validate_Mandatory_fields_1</xsl:element>
   		<xsl:element name = "CcmFifValidateValueInCont">
   		<xsl:element name="value">
   			<xsl:value-of select="$addressConfirmed"/></xsl:element>
   		<xsl:element name="object_type">address</xsl:element>
   		<xsl:element name="value_type">address_type</xsl:element>
   		<xsl:element name="allowed_values">
   		   <xsl:element name="CcmFifPassingValueCont">
   			     <xsl:element name="value"></xsl:element>
   		   </xsl:element>
   		</xsl:element>
   		<xsl:element name="ignore_failure_ind">Y</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name ="CcmFifValidateValueCmd">
   		<xsl:element name ="command_id">validate_Mandatory_fields_2</xsl:element>
   		<xsl:element name = "CcmFifValidateValueInCont">
   		<xsl:element name="value">
   			<xsl:value-of select="$adsAddressId"/></xsl:element>
   		<xsl:element name="object_type">address</xsl:element>
   		<xsl:element name="value_type">address_type</xsl:element>
   		<xsl:element name="allowed_values">
   		   <xsl:element name="CcmFifPassingValueCont">
   			     <xsl:element name="value"></xsl:element>
   		   </xsl:element>
   		</xsl:element>
   		<xsl:element name="ignore_failure_ind">Y</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name ="CcmFifValidateValueCmd">
   		<xsl:element name ="command_id">validate_Mandatory_fields_3</xsl:element>
   		<xsl:element name = "CcmFifValidateValueInCont">
   		<xsl:element name="value">
   			<xsl:value-of select="$addressId"/></xsl:element>
   		<xsl:element name="object_type">address</xsl:element>
   		<xsl:element name="value_type">address_type</xsl:element>
   		<xsl:element name="allowed_values">
   		   <xsl:element name="CcmFifPassingValueCont">
   			     <xsl:element name="value"></xsl:element>
   		   </xsl:element>
   		</xsl:element>
   		<xsl:element name="ignore_failure_ind">Y</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name="CcmFifMapStringCmd">
   		<xsl:element name="command_id">map_validate_Mandatory_details</xsl:element>
   		<xsl:element name="CcmFifMapStringInCont">
   		<xsl:element name="input_string_type">[Y,N,Y];[Y,N,N]</xsl:element>
   		<xsl:element name="input_string_list">
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_Mandatory_fields_1</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifPassingValueCont">
   		 		<xsl:element name="value">;</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_Mandatory_fields_2</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifPassingValueCont">
   		 		<xsl:element name="value">;</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_Mandatory_fields_3</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		<xsl:element name="output_string_type">[Y,N]</xsl:element>
   		<xsl:element name="string_mapping_list">
   			<xsl:element name="CcmFifStringMappingCont">
   					<xsl:element name="input_string">N;N;N</xsl:element>
   					<xsl:element name="output_string">Y</xsl:element>
   				</xsl:element>
   			</xsl:element>
   				<xsl:element name="no_mapping_error">N</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name="CcmFifRaiseErrorCmd">
                  <xsl:element name="command_id">Mandatory_feilds</xsl:element>
                  <xsl:element name="CcmFifRaiseErrorInCont">
                      <xsl:element name="error_text">
                          <xsl:text> please provide all mandatory feilds: AddressId,AddressConfirmed,AdsAddressId</xsl:text>
                      </xsl:element>
                      <xsl:element name="process_ind_ref">
                          <xsl:element name="command_id">map_validate_Mandatory_details</xsl:element>
                          <xsl:element name="field_name">output_string_found</xsl:element>
                      </xsl:element>
                      <xsl:element name="required_process_ind">N</xsl:element>
                  </xsl:element>
        </xsl:element>
   		
   		
    	<xsl:element name="CcmFifGetAddressDataCmd">
    	<xsl:element name="command_id">get_address_data_1</xsl:element>
    		<xsl:element name="CcmFifGetAddressDataInCont">
   				 <xsl:element name="address_id">
    					<xsl:value-of select="$addressId"/></xsl:element>
    			 </xsl:element>
   		</xsl:element>
   		    
   		<xsl:element name="CcmFifGetEntityCmd">
   		<xsl:element name="command_id">get_entity_1</xsl:element>
   		<xsl:element name="CcmFifGetEntityInCont">
   			<xsl:element name="entity_id_ref">
   				<xsl:element name="command_id">get_address_data_1</xsl:element>
				<xsl:element name="field_name">entity_id</xsl:element>
   			</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name ="CcmFifValidateValueCmd">
   		<xsl:element name ="command_id">validate_effective_date_1</xsl:element>
   		<xsl:element name = "CcmFifValidateValueInCont">
   		<xsl:element name="value">
   				<xsl:value-of select="$effectiveDate"/>
   		</xsl:element>
   		<xsl:element name="object_type">effective_date</xsl:element>
   		<xsl:element name="value_type">effective_date_type</xsl:element>
   		<xsl:element name="allowed_values">
   			<xsl:element name="CcmFifCommandRefCont">
   				<xsl:element name="command_id">get_address_data_1</xsl:element>
   				<xsl:element name="field_name">effective_date</xsl:element>
   			</xsl:element>
   		</xsl:element>
   		<xsl:element name="ignore_failure_ind">Y</xsl:element>
   		</xsl:element>
   	    </xsl:element>
   	
   		<xsl:element name ="CcmFifValidateValueCmd">
   		<xsl:element name ="command_id">validate_customer_number_1</xsl:element>
   		<xsl:element name = "CcmFifValidateValueInCont">
   		<xsl:element name="value_ref">
   		<xsl:element name="command_id">get_entity_1</xsl:element>
		<xsl:element name="field_name">customer_number</xsl:element>
   		</xsl:element>
   		<xsl:element name="object_type">customer_number</xsl:element>
   		<xsl:element name="value_type">customer_number_type</xsl:element>
   		<xsl:element name="allowed_values"></xsl:element>
   		<xsl:element name="ignore_failure_ind">Y</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name ="CcmFifValidateValueCmd">
   		<xsl:element name ="command_id">validate_Ads_address_id_1</xsl:element>
   		<xsl:element name = "CcmFifValidateValueInCont">
   		<xsl:element name="value_ref">
   		<xsl:element name="command_id">get_address_data_1</xsl:element>
		<xsl:element name="field_name">ads_address_id</xsl:element>
   		</xsl:element>
   		<xsl:element name="object_type">ads_address_id</xsl:element>
   		<xsl:element name="value_type">ads_address_id_type</xsl:element>
   		<xsl:element name="allowed_values">
   		   <xsl:element name="CcmFifPassingValueCont">
   			     <xsl:element name="value">0</xsl:element>
   		   </xsl:element>
   		</xsl:element>
   		<xsl:element name="ignore_failure_ind">Y</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name="CcmFifMapStringCmd">
   		<xsl:element name="command_id">map_validate_effective_dates</xsl:element>
   		<xsl:element name="CcmFifMapStringInCont">
   		<xsl:element name="input_string_type">[Y,N,Y];[Y,N,N]</xsl:element>
   		<xsl:element name="input_string_list">
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_customer_number_1</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifPassingValueCont">
   		 		<xsl:element name="value">;</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_effective_date_1</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifPassingValueCont">
   		 		<xsl:element name="value">;</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_Ads_address_id_1</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		<xsl:element name="output_string_type">[Y,N]</xsl:element>
   		<xsl:element name="string_mapping_list">
   			<xsl:element name="CcmFifStringMappingCont">
   					<xsl:element name="input_string">N;Y;Y</xsl:element>
   					<xsl:element name="output_string">Y</xsl:element>
   				</xsl:element>
   			</xsl:element>
   				<xsl:element name="no_mapping_error">N</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		
   		<xsl:element name="CcmFifMapStringCmd">
   		<xsl:element name="command_id">map_validate_Address_details</xsl:element>
   		<xsl:element name="CcmFifMapStringInCont">
   		<xsl:element name="input_string_type">[N,Y];[N,N]</xsl:element>
   		<xsl:element name="input_string_list">
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_effective_date_1</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifPassingValueCont">
   		 		<xsl:element name="value">;</xsl:element>
   		</xsl:element>
   		<xsl:element name="CcmFifCommandRefCont">
   		 		<xsl:element name="command_id">validate_Ads_address_id_1</xsl:element>
   		 		<xsl:element name="field_name">success_ind</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		<xsl:element name="output_string_type">[Y,N]</xsl:element>
   		<xsl:element name="string_mapping_list">
   			<xsl:element name="CcmFifStringMappingCont">
   					<xsl:element name="input_string">Y;Y</xsl:element>
   					<xsl:element name="output_string">Y</xsl:element>
   				</xsl:element>
   			</xsl:element>
   				<xsl:element name="no_mapping_error">N</xsl:element>
   		</xsl:element>
   		</xsl:element>
   		    
       <xsl:element name="CcmFifModifyAddressCmd">
    	<xsl:element name="command_id">modify_address_1</xsl:element>
    		<xsl:element name="CcmFifModifyAddressInCont">
    			<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">get_entity_1</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
	    		</xsl:element>
   				 <xsl:element name="effective_date">
    					<xsl:value-of select="$effectiveDate"/>
    			 </xsl:element>
    			 <xsl:element name="address_id">
    					<xsl:value-of select="$addressId"/>
    			 </xsl:element>
    			 <xsl:element name="street_name">
    					<xsl:value-of select="$streetName"/>
    			 </xsl:element>
    			<xsl:element name="street_number">
    					<xsl:value-of select="$streetNumber"/>
    			 </xsl:element>
    			 <xsl:element name="post_office_box">
    					<xsl:value-of select="$postOfficeBox"/>
    			 </xsl:element>
    			 <xsl:element name="postal_code">
    					<xsl:value-of select="$PostalCode"/>
    			 </xsl:element>
    			 <xsl:element name="city_name">
    					<xsl:value-of select="$cityName"/>
    			 </xsl:element>
    			 <xsl:element name="city_suffix_name">
    					<xsl:value-of select="$citySuffix"/>
    			 </xsl:element>
    			 <xsl:element name="country">
    					<xsl:if test="$countryCode='DEU'">
    					<xsl:text>DE</xsl:text>
    				  </xsl:if>
    				  <xsl:if test="$countryCode='DE'">
    					<xsl:text>DE</xsl:text>
    				  </xsl:if>
    				  <xsl:if test="$countryCode='D'">
    					<xsl:text>DE</xsl:text>
    				  </xsl:if>
    			 </xsl:element>
    			 <xsl:element name="ignore_if_object_exists">Y</xsl:element>
    			 <xsl:element name="process_ind_ref">
            	 <xsl:element name="command_id">map_validate_Address_details</xsl:element>
                 <xsl:element name="field_name">output_string_found</xsl:element>
                 </xsl:element>
                 <xsl:element name="required_process_ind">Y</xsl:element>
                 
    			 <xsl:element name="address_confirmed">
    					<xsl:value-of select="$addressConfirmed"/>
    			 </xsl:element>
    			 <xsl:element name="ads_address_id">
    					<xsl:value-of select="$adsAddressId"/>
    			 </xsl:element>
    			 <xsl:element name="district">
    					<xsl:value-of select="$district"/>
    			 </xsl:element>
    			 <xsl:element name="number_suffix">
    					<xsl:value-of select="$numberSuffix"/>
    			 </xsl:element>
   		    </xsl:element>
   		</xsl:element>
   		
   		
   		<xsl:element name="CcmFifCreateContactCmd">
		<xsl:element name="command_id">create_contact_1</xsl:element>
		<xsl:element name="CcmFifCreateContactInCont">
		<xsl:element name="customer_number_ref">
		<xsl:element name="command_id">get_entity_1</xsl:element>
		<xsl:element name="field_name">customer_number</xsl:element>
	    </xsl:element>
	    <xsl:element name="contact_type_rd">ADR</xsl:element>
        <xsl:element name="short_description">Migration</xsl:element>
		<xsl:element name="long_description_text">
		 <xsl:text>TransactionId: </xsl:text>
		 <xsl:value-of select="request-param[@name='transactionID']"/>
		 <xsl:text>(SLS).  Addresse  </xsl:text>
		 <xsl:value-of select="$addressId"/>
		 <xsl:text>  geändert für ADS Datenmigration.  </xsl:text>
		</xsl:element>
		<xsl:element name="ignore_no_customer_error">Y</xsl:element>
		<xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_validate_effective_dates</xsl:element>
            <xsl:element name="field_name">output_string_found</xsl:element>
         </xsl:element>
         <xsl:element name="required_process_ind">Y</xsl:element>
   		</xsl:element>
   		</xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
