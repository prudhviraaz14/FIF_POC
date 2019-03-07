<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing the billing address

  @author iarizova
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
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
          <xsl:when test ="request-param[@name='effectiveDate'] = ''">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='effectiveDate']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
            
          	
      <!-- Get Document Recipient -->
      <xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
        <xsl:element name="command_id">get_document_recipient_1</xsl:element>
        <xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    	
      <!-- if the attribute account number is populated it is necessary -->
      <!-- to create a new entity, address and assign them to new       -->
      <!-- document recipient                                           -->
      <xsl:if test="request-param[@name='accountNumber'] != ''">
         <!-- Create Entity -->
         <xsl:element name="CcmFifCreateEntityCmd">
           <xsl:element name="command_id">create_entity_1</xsl:element>
           <xsl:element name="CcmFifCreateEntityInCont">
              <xsl:if test="request-param[@name='organizationTypeRd'] != ''">
                 <xsl:element name="entity_type">O</xsl:element>
                 <xsl:element name="salutation_description">
                    <xsl:value-of select="request-param[@name='salutationDescription']"/>
                 </xsl:element>
                 <xsl:element name="name">
                    <xsl:value-of select="request-param[@name='name']"/>
                 </xsl:element>
                 <xsl:element name="organization_type_rd">
                    <xsl:value-of select="request-param[@name='organizationTypeRd']"/>
                 </xsl:element>
                 <xsl:if test="request-param[@name='organizationSuffixName'] != ''">
                    <xsl:element name="organization_suffix_name">
                       <xsl:value-of select="request-param[@name='organizationSuffixName']"/>
                    </xsl:element>
                 </xsl:if>
              </xsl:if>
              <xsl:if test="(request-param[@name='organizationTypeRd'] = '') or
                             (count(request-param[@name='organizationTypeRd']) = 0)">
                 <xsl:element name="entity_type">I</xsl:element>
                 <xsl:element name="salutation_description">
                    <xsl:value-of select="request-param[@name='salutationDescription']"/>
                 </xsl:element>
                 <xsl:if test="request-param[@name='titleDescription'] != ''">
                    <xsl:element name="title_description">
                       <xsl:value-of select="request-param[@name='titleDescription']"/>
                    </xsl:element>
                 </xsl:if>
                 <xsl:if test="request-param[@name='nobilityPrefixDescription'] != ''">
                    <xsl:element name="nobility_prefix_description">
                       <xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
                    </xsl:element>
                 </xsl:if>
                 <xsl:if test="request-param[@name='forename'] != ''">
                    <xsl:element name="forename">
                       <xsl:value-of select="request-param[@name='forename']"/>
                    </xsl:element>
                 </xsl:if>
                 <xsl:if test="request-param[@name='surnamePrefixDescription'] != ''">
                    <xsl:element name="surname_prefix_description">
                       <xsl:value-of select="request-param[@name='surnamePrefixDescription']"/>
                    </xsl:element>
                 </xsl:if>
                 <xsl:element name="name">
                    <xsl:value-of select="request-param[@name='name']"/>
                 </xsl:element>
                 <xsl:if test="request-param[@name='birthDate'] != ''">
                    <xsl:element name="birth_date">
                       <xsl:value-of select="request-param[@name='birthDate']"/>
                    </xsl:element>
                 </xsl:if>
              </xsl:if>
           </xsl:element>
         </xsl:element>

         <!-- Create Address -->
         <xsl:element name="CcmFifCreateAddressCmd">
           <xsl:element name="command_id">create_address_1</xsl:element>
              <xsl:element name="CcmFifCreateAddressInCont">
              <xsl:element name="entity_ref">
                 <xsl:element name="command_id">create_entity_1</xsl:element>
                 <xsl:element name="field_name">entity_id</xsl:element>
              </xsl:element>
              <xsl:element name="address_type">STD</xsl:element>
              <xsl:element name="street_name">
                 <xsl:value-of select="request-param[@name='newStreet']"/>
              </xsl:element>
              <xsl:element name="street_number">
                 <xsl:value-of select="request-param[@name='newNumber']"/>
              </xsl:element>
              <xsl:if test="request-param[@name='newNumberSuffix'] != ''">
                 <xsl:element name="street_number_suffix">
                    <xsl:value-of select="request-param[@name='newNumberSuffix']"/>
                 </xsl:element>
              </xsl:if>
              <xsl:element name="postal_code">
                 <xsl:value-of select="request-param[@name='newPostalCode']"/>
              </xsl:element>
              <xsl:element name="city_name">
                 <xsl:value-of select="request-param[@name='newCity']"/>
              </xsl:element>
              <xsl:if test="request-param[@name='newCitySuffix'] != ''">
                 <xsl:element name="city_suffix_name">
                    <xsl:value-of select="request-param[@name='newCitySuffix']"/>
                 </xsl:element>
              </xsl:if>
              <xsl:element name="country_code">DE</xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- Get Document Recipient    -->
         <xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
           <xsl:element name="command_id">get_document_recipient_1</xsl:element>
           <xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
              <xsl:element name="customer_number">
                 <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
              <xsl:element name="account_number">
                 <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>
           </xsl:element>
         </xsl:element>
         
         <!-- if the field access information id is not specified    -->
         <!-- it is necessary to creaty a new one and take           -->
         <!-- all parameters from already existed access information -->
         <!-- from the old entity                                    -->

         <xsl:if test="(request-param[@name='accessInformationId'] = '')
                       or (count(request-param[@name='accessInformationId']) = 0)">
            <!-- Get access information    -->
            <xsl:element name="CcmFifGetAccessInfoCmd">
               <xsl:element name="command_id">get_access_information_1</xsl:element>
               <xsl:element name="CcmFifGetAccessInfoInCont">
                  <xsl:element name="access_information_ref">
                     <xsl:element name="command_id">get_document_recipient_1</xsl:element>
                     <xsl:element name="field_name">access_information_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="effective_date">
                     <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifUpdateAccessInformCmd">
               <xsl:element name="command_id">create_access_information_1</xsl:element>
               <xsl:element name="CcmFifUpdateAccessInformInCont">
                  <xsl:element name="entity_ref">
                     <xsl:element name="command_id">create_entity_1</xsl:element>
                     <xsl:element name="field_name">entity_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="effective_date">
                     <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
                  <xsl:element name="access_information_type_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">access_information_type_rd</xsl:element>
                  </xsl:element>
                  <xsl:element name="contact_name_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">contact_name</xsl:element>
                  </xsl:element>
                  <xsl:element name="phone_number_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">phone_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="mobile_number_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">mobile_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="fax_number_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">fax_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="email_address_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">email_address</xsl:element>
                  </xsl:element>
                  <xsl:element name="electronic_contact_indicator_ref">
                     <xsl:element name="command_id">get_access_information_1</xsl:element>
                     <xsl:element name="field_name">electronic_contact_indicator</xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            
         </xsl:if>
         
         <!-- Modify Document Recipient -->
         <xsl:element name="CcmFifModifyDocumentRecipientCmd">
           <xsl:element name="command_id">modify_document_recipient_1</xsl:element>
           <xsl:element name="CcmFifModifyDocumentRecipientInCont">
              <xsl:element name="document_recipient_ref">
                 <xsl:element name="command_id">get_document_recipient_1</xsl:element>
                 <xsl:element name="field_name">document_recipient_id</xsl:element>
              </xsl:element>
              <xsl:element name="effective_date">
                 <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="entity_ref">
                 <xsl:element name="command_id">create_entity_1</xsl:element>
                 <xsl:element name="field_name">entity_id</xsl:element>
              </xsl:element>
              <xsl:if test="request-param[@name='accessInformationId'] != ''">
                 <xsl:element name="access_information_id">
                    <xsl:value-of select="request-param[@name='accessInformationId']"/>
                 </xsl:element>
              </xsl:if>
              <xsl:if test="(request-param[@name='accessInformationId'] = '')
                       or (count(request-param[@name='accessInformationId']) = 0)">
                 <xsl:element name="access_information_ref">
                    <xsl:element name="command_id">create_access_information_1</xsl:element>
                    <xsl:element name="field_name">access_information_id</xsl:element>
                 </xsl:element>
              </xsl:if>
              <xsl:element name="address_ref">
                 <xsl:element name="command_id">create_address_1</xsl:element>
                 <xsl:element name="field_name">address_id</xsl:element>
              </xsl:element>
           </xsl:element>
         </xsl:element>
      </xsl:if>
      
      <xsl:if test="(request-param[@name='accountNumber'] = '') or
                     (count(request-param[@name='accountNumber']) = 0)">
         <!-- Get Billing Address -->
         <xsl:element name="CcmFifGetBillingAddressCmd">
           <xsl:element name="command_id">get_bill_addr_1</xsl:element>
           <xsl:element name="CcmFifGetBillingAddressInCont">
             <xsl:element name="customer_number">
               <xsl:value-of select="request-param[@name='customerNumber']"/>
             </xsl:element>
             <xsl:element name="effective_date">
               <xsl:value-of select="$DesiredDate"/>
             </xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- check if the address is of type STD -->
         <xsl:element name="CcmFifIsAddressTypeCmd">
           <xsl:element name="command_id">is_address_type_1</xsl:element>
           <xsl:element name="CcmFifIsAddressTypeInCont">
             <xsl:element name="address_id_ref">
               <xsl:element name="command_id">get_bill_addr_1</xsl:element>
               <xsl:element name="field_name">address_id</xsl:element>
             </xsl:element>
             <xsl:element name="address_type">VERS</xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- create a new address, if it is a STD address -->
         <xsl:element name="CcmFifCreateAddressCmd">
           <xsl:element name="command_id">create_address_1</xsl:element>
             <xsl:element name="CcmFifCreateAddressInCont">
             <xsl:element name="entity_ref">
               <xsl:element name="command_id">get_document_recipient_1</xsl:element>
               <xsl:element name="field_name">entity_id</xsl:element>
             </xsl:element>
             <xsl:element name="address_type">VERS</xsl:element>
             <xsl:element name="street_name">
               <xsl:value-of select="request-param[@name='newStreet']"/>
             </xsl:element>
             <xsl:element name="street_number">
               <xsl:value-of select="request-param[@name='newNumber']"/>
             </xsl:element>
             <xsl:element name="street_number_suffix">
               <xsl:value-of select="request-param[@name='newNumberSuffix']"/>
             </xsl:element>
             <xsl:element name="postal_code">
               <xsl:value-of select="request-param[@name='newPostalCode']"/>
             </xsl:element>
             <xsl:element name="city_name">
               <xsl:value-of select="request-param[@name='newCity']"/>
             </xsl:element>
             <xsl:element name="city_suffix_name">
               <xsl:value-of select="request-param[@name='newCitySuffix']"/>
             </xsl:element>
             <xsl:element name="country_code">DE</xsl:element>
             <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">is_address_type_1</xsl:element>
               <xsl:element name="field_name">is_address_type</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">N</xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- Modify Document Recipient -->
         <xsl:element name="CcmFifModifyDocumentRecipientCmd">
           <xsl:element name="command_id">modify_document_recipient_1</xsl:element>
           <xsl:element name="CcmFifModifyDocumentRecipientInCont">
             <xsl:element name="document_recipient_ref">
               <xsl:element name="command_id">get_document_recipient_1</xsl:element>
               <xsl:element name="field_name">document_recipient_id</xsl:element>
             </xsl:element>
             <xsl:element name="effective_date">
               <xsl:value-of select="$DesiredDate"/>
             </xsl:element>
             <xsl:element name="entity_ref">
               <xsl:element name="command_id">get_document_recipient_1</xsl:element>
               <xsl:element name="field_name">entity_id</xsl:element>
             </xsl:element>
             <xsl:element name="access_information_ref">
               <xsl:element name="command_id">get_document_recipient_1</xsl:element>
               <xsl:element name="field_name">access_information_id</xsl:element>
             </xsl:element>
             <xsl:element name="address_ref">
               <xsl:element name="command_id">create_address_1</xsl:element>
               <xsl:element name="field_name">address_id</xsl:element>
             </xsl:element>
             <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">is_address_type_1</xsl:element>
               <xsl:element name="field_name">is_address_type</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">N</xsl:element>
           </xsl:element>
         </xsl:element>

         <!-- Modify Billing Address, if the current billing address is not 
         	  a STD address -->
         <xsl:element name="CcmFifModifyAddressCmd">
           <xsl:element name="command_id">modify_addr_1</xsl:element>
           <xsl:element name="CcmFifModifyAddressInCont">
             <xsl:element name="customer_number">
               <xsl:value-of select="request-param[@name='customerNumber']"/>
             </xsl:element>
             <xsl:element name="effective_date">
               <xsl:value-of select="$DesiredDate"/>
             </xsl:element>
             <xsl:element name="address_ref">
               <xsl:element name="command_id">get_bill_addr_1</xsl:element>
               <xsl:element name="field_name">address_id</xsl:element>
             </xsl:element>
             <xsl:element name="street_name">
               <xsl:value-of select="request-param[@name='newStreet']"/>
             </xsl:element>
             <xsl:element name="street_number">
               <xsl:value-of select="request-param[@name='newNumber']"/>
             </xsl:element>
             <xsl:element name="street_number_suffix">
               <xsl:value-of select="request-param[@name='newNumberSuffix']"/>
             </xsl:element>
             <xsl:element name="postal_code">
               <xsl:value-of select="request-param[@name='newPostalCode']"/>
             </xsl:element>
             <xsl:element name="city_name">
               <xsl:value-of select="request-param[@name='newCity']"/>
             </xsl:element>
             <xsl:element name="city_suffix_name">
               <xsl:value-of select="request-param[@name='newCitySuffix']"/>
             </xsl:element>
             <xsl:element name="process_ind_ref">
               <xsl:element name="command_id">is_address_type_1</xsl:element>
               <xsl:element name="field_name">is_address_type</xsl:element>
             </xsl:element>
             <xsl:element name="required_process_ind">Y</xsl:element>
           </xsl:element>
         </xsl:element>
      </xsl:if>
      
      <!-- Create Contact-->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact_1</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">ADR</xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='userName']"/>
          </xsl:element>
          <xsl:element name="short_description">Changing the billing address.</xsl:element>
 
          <xsl:element name="long_description_text">
            <xsl:text>The billing address: </xsl:text>
            <xsl:text>S&#xA;Street: </xsl:text>            
            <xsl:value-of select="request-param[@name='newStreet']"/>
            <xsl:text>S&#xA;Street number: </xsl:text>            
            <xsl:value-of select="request-param[@name='newNumber']"/>    
            <xsl:text>S&#xA;Postal Code: </xsl:text>            
            <xsl:value-of select="request-param[@name='newPostalCode']"/> 
            <xsl:text>S&#xA;City: </xsl:text>            
            <xsl:value-of select="request-param[@name='newCity']"/>         
            <xsl:text>&#xA; Created by: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>	
            <xsl:text>&#xA;Desired date: </xsl:text>						
             <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
 
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
