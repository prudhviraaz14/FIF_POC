<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for writing to External Notification
  
  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
                                                                                
      <xsl:variable name="actionName">
        <xsl:value-of select="request-param[@name='actionName']"/>
      </xsl:variable>
      
      <xsl:choose>
        
        <xsl:when test="$actionName = 'modifyAccountMigration'">
  
          
          <xsl:variable name="bank_account_id">
          <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
            <xsl:if test="request-param[@name='name'] = 'INTERNAL_TEXT'">
              <xsl:value-of select="substring(request-param[@name='value'],1,16)"/>
            </xsl:if>    
            </xsl:for-each> 
          </xsl:variable>
          
          <xsl:variable name="error_code">       
            <xsl:for-each select="request-param-list[@name='errorMessages']/request-param-list-item">
              <xsl:value-of select="request-param[@name='errorCode']"/>              
            </xsl:for-each>                            
          </xsl:variable>
          
          <xsl:variable name="error_code_short"> 
            <xsl:value-of select="substring($error_code,1,6)"/>              
          </xsl:variable> 
          
          <xsl:variable name="error_text">            
            <xsl:for-each select="request-param-list[@name='errorMessages']/request-param-list-item">            
              <xsl:value-of select="request-param[@name='errorText']"/>
            </xsl:for-each>                              
          </xsl:variable>
 
          <!-- update bank account migration table to ERROR_CCM -->
          <xsl:element name="CcmFifModifyRowForMigrationCmd">
            <xsl:element name="command_id">update_bank_account_migration_3</xsl:element>
            <xsl:element name="CcmFifModifyRowForMigrationInCont">
              <xsl:element name="sql_where">               
                <xsl:text>update bank_account_migration t set t.status =&apos;ERROR_CCM&apos;,</xsl:text>              
                <xsl:text> t.error_code =&apos;</xsl:text><xsl:value-of select="$error_code_short"/><xsl:text>&apos;, </xsl:text>
                <xsl:text> t.error_text =&apos;</xsl:text><xsl:value-of select="$error_text"/><xsl:text>&apos;</xsl:text>            
                <xsl:text> where t.bank_account_id=&apos;</xsl:text><xsl:value-of select="$bank_account_id"/><xsl:text>&apos; </xsl:text>
               </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:when>  
        
        <xsl:when test="$actionName = 'ReserviereKundenNummer'">
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">dummy</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">                
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">dummy</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>							
        </xsl:when>
        
        <xsl:when test="$actionName = 'releaseCustomerOrder'">
          <xsl:element name="CcmFifModifyCustomerOrderCmd">
            <xsl:element name="command_id">populate_fif_error</xsl:element>
            <xsl:element name="CcmFifModifyCustomerOrderInCont">
              <xsl:element name="customer_order_id">
                <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                  <xsl:if test="request-param[@name='name'] = 'CUSTOMER_ORDER_ID'">
                    <xsl:value-of select="request-param[@name='value']"/>
                  </xsl:if>          
                </xsl:for-each>    
              </xsl:element>        
              <xsl:element name="fif_transaction_status">                
                <xsl:for-each select="request-param-list[@name='errorMessages']/request-param-list-item">
                  <xsl:value-of select="request-param[@name='errorCode']"/>
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="request-param[@name='errorText']"/>
                  <xsl:text>, </xsl:text>
                </xsl:for-each>                  
              </xsl:element>
            </xsl:element>
          </xsl:element>							
        </xsl:when>

        <xsl:otherwise>      
          <xsl:variable name="transactionId">
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'transactionID'">
                <xsl:value-of select="request-param[@name='value']"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          
          <xsl:variable name="clientName">
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'clientName' 
                or request-param[@name='name'] = 'CLIENT_NAME'">
                <xsl:value-of select="request-param[@name='value']"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          
          <xsl:variable name="customerNumber">
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'Kundennummer'
                or request-param[@name='name'] = 'customerNumber'
                or request-param[@name='name'] = 'CUSTOMER_NUMBER'
                or request-param[@name='name'] = 'Kundeninformation;NatPerson;Kundennummer'
                or request-param[@name='name'] = 'Kundeninformation;JurPerson;Kundennummer'">
                <xsl:value-of select="request-param[@name='value']"/>
              </xsl:if>          
            </xsl:for-each>   
              
          </xsl:variable>           
            <xsl:variable name="accountNumber">
                <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                    <xsl:if test="request-param[@name='name'] = 'ACCOUNT_NUMBER'">
                        <xsl:value-of select="request-param[@name='value']"/>
                    </xsl:if>          
                </xsl:for-each> 
            </xsl:variable>

          <xsl:variable name="accessNumber">
            <xsl:text>49;</xsl:text>
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'Rufnummer;Mobilvorwahl'">
                <xsl:value-of select="substring-after(request-param[@name='value'], '0')"/>
              </xsl:if>          
            </xsl:for-each>
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'Phonenumber;Prefix'">
                <xsl:value-of select="request-param[@name='value']"/>
              </xsl:if>
            </xsl:for-each>
            <xsl:text>;</xsl:text>
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'Rufnummer;Mobilfunkrufnummer'">
                <xsl:value-of select="request-param[@name='value']"/>
              </xsl:if>          
            </xsl:for-each>    
            <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
              <xsl:if test="request-param[@name='name'] = 'Phonenumber;Number'">
                <xsl:value-of select="request-param[@name='value']"/>
              </xsl:if>
            </xsl:for-each>        
          </xsl:variable>
          
          <xsl:variable name="kbaCategory">
              <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                  <xsl:if test="request-param[@name='name'] = 'KBA_CATEGORY'">
                      <xsl:value-of select="request-param[@name='value']"/>
                  </xsl:if>          
              </xsl:for-each> 
          </xsl:variable>

          <xsl:variable name="terminationReason">
              <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                  <xsl:if test="request-param[@name='name'] = 'TERMINATION_REASON'">
                      <xsl:value-of select="request-param[@name='value']"/>
                  </xsl:if>          
              </xsl:for-each> 
          </xsl:variable>

          <xsl:variable name="serviceCode">
              <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                  <xsl:if test="request-param[@name='name'] = 'serviceCode'">
                      <xsl:value-of select="request-param[@name='value']"/>
                  </xsl:if>          
              </xsl:for-each> 
          </xsl:variable>

          <xsl:variable name="serviceSubscriptionId">
              <xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
                  <xsl:if test="request-param[@name='name'] = 'serviceSubscriptionId'
                  or request-param[@name='name'] = 'SERVICE_SUBSCRIPTION_ID'">
                      <xsl:value-of select="request-param[@name='value']"/>
                  </xsl:if>          
              </xsl:for-each> 
          </xsl:variable>

          <xsl:variable name="ccmContactType">
            <xsl:choose>
              <xsl:when test="$actionName = 'MeldeTarifwechsel'">
                <xsl:text>MOBILETARIFCHG</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'AktiviereMobilfunkVertrag'">
                <xsl:text>CREATE_MOBILE</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'ErstelleMobilfunkVertrag'">
                <xsl:text>CREATE_MOBILE</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'ModifyEueCustomerData'">
                <xsl:text>MASTERDATAUPDATE</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'MeldeStarteEingehendeRufnummerPortierung'">
                <xsl:text>PORT_MOBILE</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'ModifiziereMarketingeinwilligung'">
                <xsl:text>CUSTOMER</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'terminateServiceByAccountViaSOM'">
                <xsl:text>AUTO_TERM</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'terminateServiceByAccountWinrun'">
                <xsl:text>AUTO_TERM</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'terminateTariffOption'">
                <xsl:text>MODIFY_TARIF_OPT</xsl:text>
              </xsl:when>
              <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <xsl:variable name="kbaContactCategory">
            <xsl:choose>
              <xsl:when test="$actionName = 'MeldeTarifwechsel'">
                <xsl:text>ErrorClearingMobileTariffChange</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'AktiviereMobilfunkVertrag'">
                <xsl:text>MobilePhoneActivationNegative</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'ErstelleMobilfunkVertrag'">
                <xsl:text>ErrorClearingMobileLaterOrder</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'MeldeStarteEingehendeRufnummerPortierung'">
                <xsl:text>OrderMobilePortabilityToArcorNegative</xsl:text>
              </xsl:when>  
              <xsl:when test="$actionName = 'terminateServiceByAccountViaSOM'">
                <xsl:text>TerminationError</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'terminateServiceByAccountWinrun'">
	              <xsl:choose>
		              <xsl:when test="$kbaCategory = ''">				
		                <xsl:choose>
			                <xsl:when test="$terminationReason = 'AGKM'
                                         or $terminationReason = 'AGKB'
                                         or $terminationReason = 'AGKI'">
                           <xsl:text>TerminationErrorFIFDunning</xsl:text>
                         </xsl:when>                
			                <xsl:otherwise>
                           <xsl:text>TerminationErrorFIF</xsl:text>
			                </xsl:otherwise>				
		                </xsl:choose>
                    </xsl:when>                
		              <xsl:otherwise>
			              <xsl:value-of select="$kbaCategory"/>
		              </xsl:otherwise>				
	              </xsl:choose>
              </xsl:when>
              <xsl:when test="$actionName = 'terminateTariffOption'">
                <xsl:text>ClearingTerminateOption</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          
          <xsl:variable name="kbaContactType">
            <xsl:choose>
              <xsl:when test="$actionName = 'AktiviereMobilfunkVertrag'
                or $actionName = 'ErstelleMobilfunkVertrag'
                or $actionName = 'MeldeTarifwechsel'
                or $actionName = 'MeldeStarteEingehendeRufnummerPortierung'
                or $actionName = 'terminateServiceByAccountViaSOM'
                or $actionName = 'terminateServiceByAccountWinrun'
                or $actionName = 'terminateTariffOption'">
                <xsl:text>PROCESS</xsl:text>
              </xsl:when>
              <xsl:otherwise>CONTACT</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <xsl:variable name="description">
            <xsl:choose>
              <xsl:when test="$actionName = 'MeldeTarifwechsel'">
                <xsl:text>Mobil-TW fehlgeschlagen</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'AktiviereMobilfunkVertrag'">
                <xsl:text>SIM-Aktivierung fehlgeschlagen</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'ErstelleMobilfunkVertrag'">
                <xsl:text>Mobilfunkanlage fehlgeschlagen</xsl:text>
              </xsl:when>
              <xsl:when test="$actionName = 'MeldeStarteEingehendeRufnummerPortierung'">
                <xsl:text>Mobilportierung fehlgeschlagen</xsl:text>
              </xsl:when> 
              <xsl:when test="$actionName = 'terminateServiceByAccountViaSOM'">
                <xsl:text>SAP-Kündigung fehlgeschlagen</xsl:text>
              </xsl:when> 
              <xsl:when test="$actionName = 'terminateServiceByAccountWinrun'">
                <xsl:text>Auto-Kündigung fehlgeschlagen</xsl:text>
              </xsl:when> 
              <xsl:otherwise>FIF-Transaktion fehlgeschlagen</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <xsl:if test="$accountNumber != ''">
            <!-- get account data -->
            <xsl:element name="CcmFifGetAccountDataCmd">
              <xsl:element name="command_id">find_customer_number</xsl:element>
              <xsl:element name="CcmFifGetAccountDataInCont">
                <xsl:element name="account_number">
                  <xsl:value-of select="$accountNumber"/>                                                 
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="dateutils:getCurrentDate()"/>                                                 
                </xsl:element>                
              </xsl:element>    
            </xsl:element>   
          </xsl:if>
          
            <xsl:if test="$serviceSubscriptionId != ''">
            <!-- if service subscription id is provided -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_customer_number</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="$serviceSubscriptionId"/>
                </xsl:element>
                <xsl:element name="ignore_pending_termination">Y</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>

            <xsl:if test="$customerNumber = '' and $accountNumber = '' and $serviceSubscriptionId = ''">
            <!-- if access number is provided -->
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_customer_number</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="access_number">
                  <xsl:value-of select="$accessNumber"/>
                </xsl:element>
                <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
                <xsl:element name="ignore_pending_termination">Y</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          
          <xsl:variable name="contactText">
            <xsl:text>FIF-Transaktion </xsl:text>
            <xsl:value-of select="$actionName"/>
            <xsl:text>, TransactionId: </xsl:text>
            <xsl:value-of select="$transactionId"/>
            <xsl:text>, FIF-Client: </xsl:text>
            <xsl:value-of select="$clientName"/>
            <xsl:text>, schlug mit folgenden Meldungen fehl:</xsl:text>
            <xsl:if test="$actionName = 'terminateTariffOption'">
              <xsl:text>&#xA;Kündigung der Tarifoption </xsl:text>
              <xsl:value-of select="$serviceCode"/>
              <xsl:text> (Dienstenutzung </xsl:text>
              <xsl:value-of select="$serviceSubscriptionId"/>
              <xsl:text>) konnte nicht durchgeführt werden. Bitte manuell prüfen und ausführen!</xsl:text>
            </xsl:if> 
            <xsl:if test="$actionName != 'terminateTariffOption'">
              <xsl:for-each select="request-param-list[@name='errorMessages']/request-param-list-item">
                <xsl:text>&#xA;Fehlercode: </xsl:text>
                <xsl:value-of select="request-param[@name='errorCode']"/>
                <xsl:text>&#xA;Fehlermeldung: </xsl:text>
                <xsl:value-of select="request-param[@name='errorText']"/>
                <xsl:if test="$actionName = 'AktiviereMobilfunkVertrag'
                  and request-param[@name='errorCode'] = '142516'">
                  <xsl:text>&#xA;mögliche Ursache: Aktivierung bereits durchgeführt (zB manuell in CCM)</xsl:text>
                </xsl:if>
                <xsl:if test="$actionName = 'AktiviereMobilfunkVertrag'
                  and request-param[@name='errorCode'] = '146000'">
                  <xsl:text>&#xA;mögliche Ursache: Karte bereits gekündigt, Rufnummer unbekannt (zB manuell in CCM falsch eingegeben)</xsl:text>
                </xsl:if>
                <xsl:if test="$actionName = 'ErstelleMobilfunkVertrag'
                  and request-param[@name='errorCode'] = '142132'">
                  <xsl:text>&#xA;mögliche Ursache: Kunde/Rechnungskonto gesperrt</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:if> 
          </xsl:variable>
          
          <!-- create contact -->
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="command_id">create_contact</xsl:element>
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:choose>
                <xsl:when test="$customerNumber = ''">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_customer_number</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="customer_number">
                    <xsl:value-of select="$customerNumber"/>
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:element name="contact_type_rd">
                <xsl:value-of select="$ccmContactType"/>
              </xsl:element>
              <xsl:element name="short_description">
                <xsl:value-of select="$description"/>
              </xsl:element>
              <xsl:element name="long_description_text">
                <xsl:value-of select="$contactText"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:if test="$kbaContactCategory != ''">
            <!-- Create external notification -->
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
              <xsl:element name="command_id">create_kba_notification</xsl:element>
              <xsl:element name="CcmFifCreateExternalNotificationInCont">
                <xsl:element name="effective_date">
                  <xsl:value-of select="dateutils:getCurrentDate()"/>
                </xsl:element>
                <xsl:element name="notification_action_name">createKBANotification</xsl:element>
                <xsl:element name="target_system">KBA</xsl:element>                           				
                <xsl:element name="parameter_value_list">
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>		
                    <xsl:choose>
                      <xsl:when test="$customerNumber = ''">
                        <xsl:element name="parameter_value_ref">
                          <xsl:element name="command_id">find_customer_number</xsl:element>
                          <xsl:element name="field_name">customer_number</xsl:element>
                        </xsl:element>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:element name="parameter_value">
                          <xsl:value-of select="$customerNumber"/>
                        </xsl:element>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">TYPE</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$kbaContactType"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">CATEGORY</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$kbaContactCategory"/>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">USER_NAME</xsl:element>
                    <xsl:element name="parameter_value">FIF</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                    <xsl:element name="parameter_value">CCB</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="dateutils:getCurrentDate()"/>
                    </xsl:element>
                  </xsl:element>					
                  <xsl:element name="CcmFifParameterValueCont">
                    <xsl:element name="parameter_name">TEXT</xsl:element>
                    <xsl:element name="parameter_value">
                      <xsl:value-of select="$contactText"/>
                    </xsl:element>
                  </xsl:element>					
                </xsl:element>
              </xsl:element>
            </xsl:element>                  
          </xsl:if>          
        </xsl:otherwise>
        
      </xsl:choose>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
