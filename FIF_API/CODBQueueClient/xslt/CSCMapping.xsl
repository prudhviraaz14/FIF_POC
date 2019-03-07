<xsl:if test="$serviceCharCode != ''">
  <xsl:if test="$dataType = 'MAIN_ACCESS_NUM' or $dataType = 'MOBIL_ACCESS_NUM'">
    <xsl:element name="CcmFifAccessNumberCont">
      <xsl:element name="service_char_code">
        <xsl:value-of select="$serviceCharCode"/>
      </xsl:element>
      <xsl:element name="data_type">
        <xsl:value-of select="$dataType"/>
      </xsl:element>    
      <xsl:element name="validate_duplicate_indicator">
        <xsl:value-of select="../../request-param[@name='validateDuplicateAccessNumbers']"/>
      </xsl:element>
      <xsl:choose>
        <xsl:when test="request-param[@name='action'] = 'remove'">
          <xsl:element name="country_code"/>
          <xsl:element name="city_code"/>
          <xsl:element name="local_number"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="country_code">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredCountryCode'] != ''">
                <xsl:value-of select="request-param[@name='configuredCountryCode']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingCountryCode']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="city_code">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredAreaCode'] != ''">
                <xsl:value-of select="request-param[@name='configuredAreaCode']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingAreaCode']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="local_number">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredLocalNumber'] != ''">
                <xsl:value-of select="request-param[@name='configuredLocalNumber']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingLocalNumber']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:if>                                  
  <xsl:if test="$dataType = 'ACC_NUM_RANGE'">
    <xsl:element name="CcmFifAccessNumberCont">
      <xsl:element name="service_char_code">
        <xsl:value-of select="$serviceCharCode"/>
      </xsl:element>
      <xsl:element name="data_type">
        <xsl:value-of select="$dataType"/>
      </xsl:element>
      <xsl:element name="validate_duplicate_indicator">
        <xsl:value-of select="../../request-param[@name='validateDuplicateAccessNumbers']"/>
      </xsl:element>
      <xsl:choose>
        <xsl:when test="request-param[@name='action'] = 'remove'">
          <xsl:element name="country_code"/>
          <xsl:element name="city_code"/>
          <xsl:element name="local_number"/>
          <xsl:element name="from_ext_num"/>
          <xsl:element name="to_ext_num"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="country_code">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredCountryCode'] != ''">
                <xsl:value-of select="request-param[@name='configuredCountryCode']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingCountryCode']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="city_code">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredAreaCode'] != ''">
                <xsl:value-of select="request-param[@name='configuredAreaCode']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingAreaCode']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="local_number">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredLocalNumber'] != ''">
                <xsl:value-of select="request-param[@name='configuredLocalNumber']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingLocalNumber']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="from_ext_num">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredStartNumber'] != ''">
                <xsl:value-of select="request-param[@name='configuredStartNumber']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingStartNumber']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
          <xsl:element name="to_ext_num">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredEndNumber'] != ''">
                <xsl:value-of select="request-param[@name='configuredEndNumber']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingEndNumber']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:if>                                  
  <xsl:if test="$dataType = 'SERVICE_LOCATION'">
    <xsl:element name="CcmFifServiceLocationCont">
      <xsl:element name="service_char_code">
        <xsl:value-of select="$serviceCharCode"/>
      </xsl:element>
      <xsl:element name="data_type">
        <xsl:value-of select="$dataType"/>
      </xsl:element>
      <xsl:element name="floor">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredFloor'] != ''">
            <xsl:value-of select="request-param[@name='configuredFloor']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingFloor']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="room_number">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredRoomNumber'] != ''">
            <xsl:value-of select="request-param[@name='configuredRoomNumber']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingRoomNumber']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="jack_location">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredJackLocation'] != ''">
            <xsl:value-of select="request-param[@name='configuredJackLocation']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingJackLocation']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="desk_number">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredDeskNumber'] != ''">
            <xsl:value-of select="request-param[@name='configuredDeskNumber']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingDeskNumber']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="additional_location_info">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredAdditionalLocationInfo'] != ''">
            <xsl:value-of select="request-param[@name='configuredAdditionalLocationInfo']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingAdditionalLocationInfo']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:element>
  </xsl:if>                
  <xsl:if test="$dataType = 'TECH_SERVICE_ID' or $dataType = 'USER_ACCOUNT_NUM'">
    <xsl:choose>
      <xsl:when test="request-param[@name='action'] = 'remove'">
        <xsl:element name="CcmFifAccessNumberCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$serviceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">
            <xsl:value-of select="$dataType"/>
          </xsl:element>
          <xsl:element name="network_account"/>
        </xsl:element>
        <!-- currently (IT-28575, 1.40) we are assuming that the 2nd CSC is always a STRING -->
        <xsl:if test="$anotherServiceCharCode != ''">
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">
              <xsl:value-of select="$anotherServiceCharCode"/>
            </xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:if test="$isReconfiguration = 'Y'">**NULL**</xsl:if>          
            </xsl:element>
          </xsl:element>  
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$isReconfiguration = 'N'
          or $isReconfiguration = 'Y'
          and request-param[@name='configuredValue'] != ''
          and request-param[@name='configuredValue'] != request-param[@name='existingValue']">
          <xsl:element name="CcmFifAccessNumberCont">
            <xsl:element name="service_char_code">
              <xsl:value-of select="$serviceCharCode"/>
            </xsl:element>
            <xsl:element name="data_type">
              <xsl:value-of select="$dataType"/>
            </xsl:element>
            <xsl:element name="network_account">
              <xsl:value-of select="$value"/>
            </xsl:element>
          </xsl:element>
          <xsl:if test="$anotherServiceCharCode != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">
                <xsl:value-of select="$anotherServiceCharCode"/>
              </xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$value"/>
              </xsl:element>
            </xsl:element>          
          </xsl:if>        
        </xsl:if>      
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="$dataType = 'STRING' and $serviceCharCode != '' or 
    $dataType = 'INTEGER' or 
    $dataType = 'DECIMAL' or 
    $dataType = 'DATE' or 
    $dataType = 'BOOLEAN'">                
    <xsl:choose>
      <xsl:when test="request-param[@name='action'] = 'remove'">
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$serviceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">
            <xsl:value-of select="$dataType"/>
          </xsl:element>
          <xsl:element name="configured_value">
            <xsl:if test="$isReconfiguration = 'Y'">**NULL**</xsl:if>
          </xsl:element>
        </xsl:element>  
        <xsl:if test="$anotherServiceCharCode != ''">
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">
              <xsl:value-of select="$anotherServiceCharCode"/>
            </xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:if test="$isReconfiguration = 'Y'">**NULL**</xsl:if>          
            </xsl:element>
          </xsl:element>  
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$isReconfiguration = 'N'
          or $isReconfiguration = 'Y'
          and request-param[@name='configuredValue'] != ''
          and request-param[@name='configuredValue'] != request-param[@name='existingValue']">
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">
              <xsl:value-of select="$serviceCharCode"/>
            </xsl:element>
            <xsl:element name="data_type">
              <xsl:value-of select="$dataType"/>
            </xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="$value"/>
            </xsl:element>
          </xsl:element>
          <xsl:if test="$anotherServiceCharCode != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">
                <xsl:value-of select="$anotherServiceCharCode"/>
              </xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$value"/>
              </xsl:element>
            </xsl:element>          
          </xsl:if>
        </xsl:if>                
      </xsl:otherwise>    
    </xsl:choose>
  </xsl:if>                
  <xsl:if test="$dataType = 'LINEOWNER'">
    <xsl:choose>
      <xsl:when test="request-param[@name='action'] = 'remove'">
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$serviceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">STRING</xsl:element>
          <xsl:element name="configured_value">
            <xsl:if test="$isReconfiguration = 'Y'">**NULL**</xsl:if>
          </xsl:element>
        </xsl:element>                  
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$anotherServiceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">STRING</xsl:element>
          <xsl:element name="configured_value">
            <xsl:if test="$isReconfiguration = 'Y'">**NULL**</xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$serviceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">STRING</xsl:element>
          <xsl:element name="configured_value">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredName'] != ''">
                <xsl:value-of select="request-param[@name='configuredName']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingName']"/>
              </xsl:otherwise>
            </xsl:choose>      
          </xsl:element>
        </xsl:element>                  
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$anotherServiceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">STRING</xsl:element>
          <xsl:element name="configured_value">
            <xsl:choose>
              <xsl:when test="request-param[@name='configuredFirstName'] != ''">
                <xsl:value-of select="request-param[@name='configuredFirstName']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='existingFirstName']"/>
              </xsl:otherwise>
            </xsl:choose>      
          </xsl:element>
        </xsl:element>                        
      </xsl:otherwise>
    </xsl:choose>      
  </xsl:if>                
  <xsl:if test="$dataType = 'ADDRESS' and (
    $isReconfiguration = 'N' or
    request-param[@name='configuredStreet'] != '' or 
    request-param[@name='configuredStreetNumber'] != '' or
    request-param[@name='configuredStreetNumberSuffix'] != '' or
    request-param[@name='configuredPostalCode'] != '' or
    request-param[@name='configuredCity'] != '' or
    request-param[@name='configuredCountry'] != '')">                
    <xsl:element name="CcmFifAddressCharacteristicCont">
      <xsl:element name="service_char_code">
        <xsl:value-of select="$serviceCharCode"/>
      </xsl:element>
      <xsl:element name="data_type">ADDRESS</xsl:element>
      <xsl:element name="address_ref">
        <xsl:element name="command_id">
          <xsl:text>create_address_</xsl:text>
          <xsl:value-of select="request-param[@name='parameterName']"/>
        </xsl:element>
        <xsl:element name="field_name">address_id</xsl:element>
      </xsl:element>
    </xsl:element>						
  </xsl:if>                
  <xsl:if test="$dataType = 'IP_NET_ADDRESS'">
    <xsl:choose>
      <xsl:when test="request-param[@name='action'] = 'remove'">
        <xsl:element name="CcmFifAccessNumberCont">
          <xsl:element name="service_char_code">
            <xsl:value-of select="$serviceCharCode"/>
          </xsl:element>
          <xsl:element name="data_type">
            <xsl:value-of select="$dataType"/>
          </xsl:element>
          <xsl:element name="ip_number"/>
          <xsl:element name="subnet_mask"/>
          <xsl:element name="alias"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$isReconfiguration = 'N'
          or $isReconfiguration = 'Y'
          and request-param[@name='configuredValue'] != ''
          and request-param[@name='configuredValue'] != request-param[@name='existingValue']">
          <xsl:element name="CcmFifAccessNumberCont">
            <xsl:element name="service_char_code">
              <xsl:value-of select="$serviceCharCode"/>
            </xsl:element>
            <xsl:element name="data_type">
              <xsl:value-of select="$dataType"/>
            </xsl:element>
            <xsl:element name="ip_number">
               <xsl:choose>
                  <xsl:when test="contains($value, ';')">
                     <xsl:value-of select="substring-after(substring-after($value, ';'), ';')"/>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:value-of select="$value"/>
                 </xsl:otherwise>
               </xsl:choose>
            </xsl:element>
            <xsl:element name="subnet_mask">
              <xsl:value-of select="substring-before(substring-after($value, ';'), ';')"/>
            </xsl:element>
            <xsl:element name="alias">
              <xsl:value-of select="substring-before($value, ';')"/>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="$dataType = 'DELIVERYNAME' and request-param[@name='configuredName'] != ''">  
    <xsl:element name="CcmFifConfiguredValueCont">
      <xsl:element name="service_char_code">
        <xsl:value-of select="$serviceCharCode"/>
      </xsl:element>
      <xsl:element name="data_type">STRING</xsl:element>
      <xsl:element name="configured_value">
        <xsl:value-of select="request-param[@name='configuredSalutation']"/>
        <xsl:text>;</xsl:text>
        <xsl:value-of select="request-param[@name='configuredName']"/>
        <xsl:text>;</xsl:text>
        <xsl:value-of select="request-param[@name='configuredFirstName']"/>
      </xsl:element>
    </xsl:element>
  </xsl:if>
  <xsl:if test="$dataType = 'DIRECTORY_ENTRY'">
    <xsl:choose>
      <xsl:when test="request-param[@name='configuredDirectoryEntryText'] != ''">
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">V0100</xsl:element>
          <xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
          <xsl:element name="configured_value">
            <xsl:value-of select="request-param[@name='configuredDirectoryEntryText']"/>
          </xsl:element>
        </xsl:element>      
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="CcmFifDirectoryEntryCont">
          <xsl:element name="service_char_code">V0100</xsl:element>
          <xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
          <xsl:element name="type">01  PRN  ELewAUS</xsl:element>
          <xsl:element name="access_number">
            <xsl:value-of select="request-param[@name='configuredCountryCode']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='configuredAreaCode']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='configuredLocalNumber']"/>
          </xsl:element>
          <xsl:element name="name">
            <xsl:value-of select="request-param[@name='configuredName']"/>
          </xsl:element>
          <xsl:element name="forename">
            <xsl:value-of select="request-param[@name='configuredFirstName']"/>
          </xsl:element>
          <xsl:element name="nobility_prefix">
            <xsl:value-of select="request-param[@name='configuredNobilityPrefixDescription']"/>
          </xsl:element>
          <xsl:element name="title">
            <xsl:value-of select="request-param[@name='configuredTitleDescription']"/>
          </xsl:element>
          <xsl:element name="surname_prefix">
            <xsl:value-of select="request-param[@name='configuredSurnamePrefix']"/>
          </xsl:element>
          <xsl:element name="profession">
            <xsl:value-of select="request-param[@name='configuredProfession']"/>
          </xsl:element>
          <xsl:element name="industry_group">
            <xsl:value-of select="request-param[@name='configuredIndustrialSector']"/>
          </xsl:element>
          <xsl:element name="address_additional_text">
            <xsl:value-of select="request-param[@name='configuredAdditionalText']"/>
          </xsl:element>                                                                                                                                                                                                                                
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='configuredStreet']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='configuredStreetNumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='configuredStreetNumberSuffix']"/>
          </xsl:element>
          <xsl:element name="post_office_box">
            <xsl:value-of select="request-param[@name='configuredPostOfficeBox']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='configuredPostalCode']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='configuredCity']"/>
          </xsl:element>
          <xsl:element name="city_suffix">
            <xsl:value-of select="request-param[@name='configuredCitySuffix']"/>
          </xsl:element>
          <xsl:element name="country">DE</xsl:element>
        </xsl:element>	      
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:if>
